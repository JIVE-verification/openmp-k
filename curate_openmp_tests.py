#!/usr/bin/env python3
"""
curate_openmp_tests.py
----------------------

Curates OpenMP-focused C test cases into a top-level tests/openmp hierarchy.
See the block comment at the end of the file for usage examples.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import fnmatch
import functools
import hashlib
import json
import logging
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

try:
    import yaml  # type: ignore
except ImportError:  # pragma: no cover - best effort fallback
    yaml = None


# ----------------------------
# Utility data and structures
# ----------------------------

REPO_ROOT = Path(__file__).resolve().parent
DEFAULT_DEST = REPO_ROOT / "tests" / "openmp"
DEFAULT_MAX_KB = 250
STANDARD_HEADERS = {
    # ISO C headers (C17 list plus a few common extensions)
    "assert.h",
    "complex.h",
    "ctype.h",
    "errno.h",
    "fenv.h",
    "float.h",
    "inttypes.h",
    "iso646.h",
    "limits.h",
    "locale.h",
    "math.h",
    "setjmp.h",
    "signal.h",
    "stdalign.h",
    "stdarg.h",
    "stdbool.h",
    "stddef.h",
    "stdint.h",
    "stdio.h",
    "stdlib.h",
    "stdnoreturn.h",
    "string.h",
    "tgmath.h",
    "threads.h",
    "time.h",
    "uchar.h",
    "wchar.h",
    "wctype.h",
    # POSIX-ish headers encountered in tests
    "unistd.h",
    "pthread.h",
    "sys/types.h",
    "sys/stat.h",
    "sys/time.h",
    "sys/param.h",
    "sys/wait.h",
    "sys/mman.h",
    "sys/resource.h",
    "sys/file.h",
    "sys/ipc.h",
    "sys/sem.h",
    "sys/shm.h",
    "sys/socket.h",
    "sys/uio.h",
    "sys/utsname.h",
    "dirent.h",
    "dlfcn.h",
    "fcntl.h",
    "grp.h",
    "pwd.h",
    "semaphore.h",
    "signal.h",
    "strings.h",
    "termios.h",
    "ucontext.h",
    "utime.h",
    "utmp.h",
    "syslog.h",
    "stdatomic.h",
    # OpenMP
    "omp.h",
}

LICENSE_FILENAMES = {
    "LICENSE",
    "LICENSE.txt",
    "LICENSE.md",
    "LICENSE.rst",
    "COPYING",
    "COPYING.txt",
    "COPYING.md",
    "COPYRIGHT",
    "NOTICE",
    "NOTICE.txt",
}

OPENMP_TOKENS = (re.compile(r"#\s*include\s*<omp\.h>", re.IGNORECASE), re.compile(r"#\s*pragma\s+omp", re.IGNORECASE))

MANIFEST_VERSION = 1


@dataclass
class ProcessResult:
    status: str
    suite: Optional[str] = None
    test_id: Optional[str] = None
    message: Optional[str] = None
    error: Optional[str] = None
    changed: bool = False


@dataclass(frozen=True)
class GitInfo:
    repo_root: Optional[Path]
    remote_url: str
    head_commit: str


# ----------------------------
# Argument parsing & prompts
# ----------------------------

def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Curate OpenMP C tests into a top-level tests directory.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--dest", type=str, default=str(DEFAULT_DEST), help="Destination tests directory")
    parser.add_argument("--src", type=str, action="append", help="Source root containing OpenMP examples (repeatable)")
    parser.add_argument("--max_file_kb", type=int, default=DEFAULT_MAX_KB, help="Maximum candidate file size in kilobytes")
    parser.add_argument("--collector", type=str, default="unknown", help="Collector name or handle for citation records")
    parser.add_argument("--dry_run", action="store_true", help="Print planned actions without copying files")
    return parser.parse_args(argv)


def interactive_prompt(default_dest: Path) -> Tuple[Path, List[Path]]:
    print(f"Destination tests directory: {default_dest} (override with --dest if needed).")
    dest = default_dest
    print("Enter one or more source roots that contain OpenMP examples.")
    print("Paste absolute paths, one per line. Press Enter on a blank line to finish.")
    srcs: List[Path] = []
    while True:
        try:
            line = input()
        except EOFError:
            break
        line = line.strip()
        if not line:
            break
        srcs.append(Path(line))
    return dest, srcs


# ----------------------------
# Logging helpers
# ----------------------------

def setup_logger(dest: Path) -> logging.Logger:
    logger = logging.getLogger("curate_openmp_tests")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()

    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    log_file = dest / "curation.log"
    try:
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    except OSError:  # pragma: no cover - unlikely but we still want stdout logging
        logger.warning("Unable to open log file at %s; proceeding with stdout logging only.", log_file)
    return logger


# ----------------------------
# Ignore handling
# ----------------------------

class IgnoreMatcher:
    def __init__(self, patterns: Iterable[str]) -> None:
        cleaned: List[Tuple[str, bool]] = []
        for raw in patterns:
            pattern = raw.strip()
            if not pattern or pattern.startswith("#"):
                continue
            is_negated = pattern.startswith("!")
            if is_negated:
                pattern = pattern[1:]
            # Normalise path separators to POSIX style for fnmatch
            pattern = pattern.replace("\\", "/")
            cleaned.append((pattern, is_negated))
        self._patterns: List[Tuple[str, bool]] = cleaned

    def matches(self, rel_path: str) -> bool:
        matched = False
        for pattern, is_negated in self._patterns:
            if fnmatch.fnmatch(rel_path, pattern):
                matched = not is_negated
        return matched


def load_ignore_patterns(root: Path, dest: Path) -> IgnoreMatcher:
    patterns: List[str] = []
    gitignore = root / ".gitignore"
    if gitignore.exists():
        patterns.extend(gitignore.read_text(encoding="utf-8", errors="ignore").splitlines())
    custom_ignore = root / ".openmp_k_ignore"
    if custom_ignore.exists():
        patterns.extend(custom_ignore.read_text(encoding="utf-8", errors="ignore").splitlines())
    # Always ignore the destination tests area to avoid recursive imports
    try:
        rel_dest = dest.relative_to(root)
    except ValueError:
        rel_dest = Path(dest.name)
    patterns.append(str(rel_dest).replace("\\", "/") + "/**")
    return IgnoreMatcher(patterns)


def relative_posix(path: Path, base: Path) -> str:
    try:
        rel = path.relative_to(base)
        return rel.as_posix()
    except ValueError:
        return path.as_posix()


# ----------------------------
# Git helpers
# ----------------------------

@functools.lru_cache(maxsize=None)  # type: ignore[attr-defined]
def git_info_for(path: Path) -> GitInfo:
    """Return GitInfo for the repository containing path, if any."""
    cwd_path = path if path.is_dir() else path.parent
    if not cwd_path:
        return GitInfo(None, "unknown", "unknown")
    try:
        toplevel = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=str(cwd_path),
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        repo_root = Path(toplevel)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return GitInfo(None, "unknown", "unknown")

    try:
        remote_url = (
            subprocess.run(
            ["git", "remote", "get-url", "origin"],
                cwd=str(repo_root),
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            or "unknown"
        )
    except subprocess.CalledProcessError:
        remote_url = "unknown"

    try:
        head_commit = (
            subprocess.run(
            ["git", "rev-parse", "HEAD"],
                cwd=str(repo_root),
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            or "unknown"
        )
    except subprocess.CalledProcessError:
        head_commit = "unknown"

    return GitInfo(repo_root, remote_url, head_commit)


# ----------------------------
# File utilities
# ----------------------------

def normalise_newlines(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def write_atomic_text(path: Path, content: str) -> bool:
    path.parent.mkdir(parents=True, exist_ok=True)
    content_norm = normalise_newlines(content)
    if path.exists():
        existing = path.read_text(encoding="utf-8", errors="ignore")
        if normalise_newlines(existing) == content_norm:
            return False
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=str(path.parent), delete=False) as tmp:
        tmp.write(content_norm)
        tmp.flush()
        os.fsync(tmp.fileno())
        temp_name = Path(tmp.name)
    os.replace(temp_name, path)
    return True


def write_atomic_bytes(path: Path, data: bytes) -> bool:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == data:
        return False
    with tempfile.NamedTemporaryFile("wb", dir=str(path.parent), delete=False) as tmp:
        tmp.write(data)
        tmp.flush()
        os.fsync(tmp.fileno())
        temp_name = Path(tmp.name)
    os.replace(temp_name, path)
    return True


def remove_file(path: Path) -> bool:
    if path.exists():
        path.unlink()
        return True
    return False


def text_differs(path: Path, content: str) -> bool:
    if not path.exists():
        return True
    existing = path.read_text(encoding="utf-8", errors="ignore")
    return normalise_newlines(existing) != normalise_newlines(content)


def bytes_differs(path: Path, data: bytes) -> bool:
    if not path.exists():
        return True
    return path.read_bytes() != data


def sync_text(path: Path, content: str, dry_run: bool) -> bool:
    if dry_run:
        return text_differs(path, content)
    return write_atomic_text(path, content)


def sync_bytes(path: Path, data: bytes, dry_run: bool) -> bool:
    if dry_run:
        return bytes_differs(path, data)
    return write_atomic_bytes(path, data)


def remove_if_exists(path: Path, dry_run: bool) -> bool:
    if not path.exists():
        return False
    if dry_run:
        return True
    return remove_file(path)


def contains_openmp_tokens(content: str) -> bool:
    for token in OPENMP_TOKENS:
        if token.search(content):
            return True
    return False


def extract_includes(content: str) -> List[str]:
    includes: List[str] = []
    for line in content.splitlines():
        line = line.strip()
        if line.startswith("#include"):
            match = re.match(r'#\s*include\s*([<"].+[>"])', line)
            if match:
                includes.append(match.group(1))
    return includes


@functools.lru_cache(maxsize=1024)
def _find_header_in_root(root: str, header: str) -> Optional[str]:
    root_path = Path(root)
    if not root_path.exists():
        return None
    try:
        for candidate in root_path.rglob(header):
            if candidate.is_file():
                return str(candidate)
    except OSError:
        return None
    return None


def resolve_header_file(header: str, source_path: Path, source_root: Path, repo_root: Optional[Path]) -> Optional[Path]:
    candidate = source_path.parent / header
    if candidate.exists():
        return candidate
    stop_paths = {source_root.resolve()}
    if repo_root:
        stop_paths.add(repo_root.resolve())
    for ancestor in source_path.parents:
        candidate = ancestor / header
        if candidate.exists():
            return candidate
        if ancestor.resolve() in stop_paths:
            break
    search_roots = [source_root]
    if repo_root and repo_root != source_root:
        search_roots.append(repo_root)
    for root in search_roots:
        cached = _find_header_in_root(str(root.resolve()), header)
        if cached:
            path = Path(cached)
            if path.exists():
                return path
    return None


def locate_license_file(source: Path, stop_dirs: Sequence[Optional[Path]] = ()) -> Optional[Path]:
    stops = [p.resolve() for p in stop_dirs if p]
    upper_bound: Optional[Path] = None
    if stops:
        upper_bound = min(stops, key=lambda path: len(path.parents))
    current = source.parent.resolve()
    while True:
        for candidate in LICENSE_FILENAMES:
            candidate_path = current / candidate
            if candidate_path.exists():
                return candidate_path
        if upper_bound is not None and current == upper_bound:
            break
        parent = current.parent
        if parent == current:
            break
        current = parent
    return None


def identify_spdx(license_text: str) -> str:
    lowered = license_text.lower()
    if "spdx-license-identifier" in lowered:
        match = re.search(r"spdx-license-identifier:\s*([a-z0-9\.-]+)", license_text, flags=re.IGNORECASE)
        if match:
            return match.group(1)
    if "mit license" in lowered:
        return "MIT"
    if "apache license" in lowered and "version 2" in lowered:
        return "Apache-2.0"
    if "gnu lesser general public license" in lowered:
        if "2.1" in lowered:
            return "LGPL-2.1-or-later"
        if "3" in lowered:
            return "LGPL-3.0-or-later"
        return "LGPL-2.1-or-later"
    if "gnu general public license" in lowered:
        if "3" in lowered:
            return "GPL-3.0-or-later"
        if "2" in lowered:
            return "GPL-2.0-or-later"
        return "GPL-3.0-or-later"
    if "bsd 3-clause" in lowered or "redistribution and use" in lowered and "3 clauses" in lowered:
        return "BSD-3-Clause"
    if "bsd-3" in lowered or "bsd 3" in lowered:
        return "BSD-3-Clause"
    if "bsd 2-clause" in lowered:
        return "BSD-2-Clause"
    if "mozilla public license" in lowered:
        if "2.0" in lowered:
            return "MPL-2.0"
        return "MPL-2.0"
    if "creative commons zero" in lowered or "cc0" in lowered:
        return "CC0-1.0"
    if "artistic license" in lowered:
        return "Artistic-2.0"
    return "unknown"


def sanitise_name(name: str) -> str:
    cleaned = re.sub(r"[^a-z0-9]+", "_", name.lower())
    cleaned = cleaned.strip("_")
    return cleaned or "suite"


def slugify_path(path: Path) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", path.as_posix().lower())
    slug = re.sub(r"_+", "_", slug).strip("_")
    return slug or "test"


def compute_test_id(rel_path: Path, abs_path: Path, commit: str) -> str:
    slug = slugify_path(rel_path)
    fingerprint = hashlib.sha1(f"{abs_path.resolve()}|{commit}".encode("utf-8")).hexdigest()[:7]
    return f"{slug}_{fingerprint}"


def ensure_relative(source: Path, repo_root: Optional[Path], source_root: Path) -> Path:
    if repo_root:
        try:
            return source.relative_to(repo_root)
        except ValueError:
            pass
    try:
        return source.relative_to(source_root)
    except ValueError:
        return source


def yaml_dump(data: Dict[str, object]) -> str:
    if yaml is not None:
        return yaml.safe_dump(data, sort_keys=False, allow_unicode=True)
    # Minimal manual YAML emitter fallback
    lines: List[str] = []
    for key, value in data.items():
        if isinstance(value, str):
            lines.append(f"{key}: {value}")
        else:
            lines.append(f"{key}: {json.dumps(value)}")
    return "\n".join(lines) + "\n"


def load_json(path: Path) -> Optional[Dict[str, object]]:
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def load_yaml(path: Path) -> Optional[Dict[str, object]]:
    if not path.exists():
        return None
    try:
        if yaml is not None:
            return yaml.safe_load(path.read_text(encoding="utf-8"))
    except Exception:
        return None
    # Fallback manual parsing for simple key: value pairs
    result: Dict[str, object] = {}
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            result[key.strip()] = value.strip()
    return result


# ----------------------------
# Core processing
# ----------------------------

@dataclass
class CuratorContext:
    dest: Path
    collector: str
    max_bytes: int
    dry_run: bool
    ignore_matcher: IgnoreMatcher
    logger: logging.Logger


def process_candidate(source_path: Path, source_root: Path, context: CuratorContext) -> ProcessResult:
    logger = context.logger
    try:
        try:
            raw_content = source_path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            raw_content = source_path.read_text(encoding="latin-1")
        content = normalise_newlines(raw_content)
    except Exception as exc:
        logger.error("Failed to read %s: %s", source_path, exc)
        return ProcessResult(status="error", message=str(exc))

    if not contains_openmp_tokens(content):
        return ProcessResult(status="no_openmp")

    git_info = git_info_for(source_path)

    includes = extract_includes(content)
    header_support: Dict[str, Path] = {}
    header_uncertain = False
    for inc in includes:
        if inc.startswith("<") and inc.endswith(">"):
            header_name = inc[1:-1].strip()
            if header_name.lower() not in STANDARD_HEADERS:
                header_uncertain = True
        elif inc.startswith('"') and inc.endswith('"'):
            header_name = inc[1:-1]
            if header_name.lower() in STANDARD_HEADERS:
                continue
            resolved = resolve_header_file(header_name, source_path, source_root, git_info.repo_root)
            if resolved:
                header_support[header_name] = resolved
            else:
                header_uncertain = True
                logger.warning("Could not resolve local header '%s' for %s", header_name, source_path)
        else:
            header_uncertain = True
    # git_info already obtained above
    rel_path = ensure_relative(source_path, git_info.repo_root, source_root)
    suite_name = sanitise_name(source_root.name)
    test_id = compute_test_id(rel_path, source_path, git_info.head_commit)
    case_dir = context.dest / "cases" / suite_name / test_id
    case_src = case_dir / "src.c"
    existing = case_src.exists()
    meta_path = case_dir / "META.json"
    input_dest = case_dir / "src.in"
    citation_path = (context.dest / "CITATIONS") / f"{test_id}.yml"
    existing_meta = load_json(meta_path) or {}
    existing_citation = load_yaml(citation_path)

    license_path = locate_license_file(source_path, (git_info.repo_root, source_root))
    license_text = ""
    license_id = "unknown"
    if license_path:
        try:
            license_text = normalise_newlines(license_path.read_text(encoding="utf-8", errors="ignore"))
            license_id = identify_spdx(license_text)
        except Exception as exc:
            logger.warning("Failed to read license file %s: %s", license_path, exc)
            license_path = None
            license_text = ""
            license_id = "unknown"

    now_iso = datetime.now(timezone.utc).isoformat()
    suite_readable = suite_name or "suite"

    if git_info.repo_root:
        try:
            rel_for_citation = source_path.relative_to(git_info.repo_root)
        except ValueError:
            rel_for_citation = source_path
    else:
        rel_for_citation = source_path

    input_src = source_path.with_suffix(".in")
    changed = False

    changed |= sync_text(case_src, content, context.dry_run)

    license_dest = case_dir / "LICENSE.txt"
    license_content = license_text if license_path else "Unknown license\n"
    changed |= sync_text(license_dest, license_content, context.dry_run)

    support_headers_written: List[str] = []
    for header_name, header_path in header_support.items():
        header_target = case_dir / header_name
        try:
            header_text = normalise_newlines(header_path.read_text(encoding="utf-8"))
        except UnicodeDecodeError:
            header_text = normalise_newlines(header_path.read_text(encoding="latin-1"))
        except Exception as exc:
            logger.warning("Failed to copy header %s for %s: %s", header_path, source_path, exc)
            header_uncertain = True
            continue
        if sync_text(header_target, header_text, context.dry_run):
            changed = True
        support_headers_written.append(header_name)

    if input_src.exists():
        try:
            input_text = normalise_newlines(input_src.read_text(encoding="utf-8", errors="ignore"))
        except Exception:
            input_text = normalise_newlines(input_src.read_text(encoding="latin-1", errors="ignore"))
        changed |= sync_text(input_dest, input_text, context.dry_run)
    else:
        if remove_if_exists(input_dest, context.dry_run):
            changed = True

    citation_data = {
        "title": source_path.name,
        "source_repo_url": git_info.remote_url,
        "source_commit": git_info.head_commit if git_info.head_commit != "unknown" else "unknown",
        "source_relpath": rel_for_citation.as_posix(),
        "collected_by": context.collector or "unknown",
        "collected_at": now_iso,
        "license": license_id or "unknown",
    }
    if existing_citation:
        previous = dict(existing_citation)
        previous.pop("notes", None)
        previous.pop("collected_at", None)
        desired = dict(citation_data)
        desired.pop("collected_at", None)
        if previous == desired:
            citation_data["collected_at"] = existing_citation.get("collected_at", citation_data["collected_at"])
    citation_yaml = yaml_dump(citation_data)
    changed |= sync_text(citation_path, citation_yaml, context.dry_run)

    base_meta = {
        "language": "C",
        "requires_openmp": True,
        "imports": ["omp.h"],
        "tags": ["openmp", "auto-curated"],
        "source": f"../../../CITATIONS/{test_id}.yml",
    }
    if header_uncertain:
        base_meta["header_check"] = "uncertain"
    if input_src.exists():
        base_meta["input_file"] = "src.in"
    if support_headers_written:
        base_meta["support_headers"] = sorted(set(support_headers_written))
    extra_keys = {
        k: v
        for k, v in existing_meta.items()
        if k
        not in {
            "language",
            "requires_openmp",
            "imports",
            "tags",
            "source",
            "imported_at",
            "input_file",
            "header_check",
            "support_headers",
        }
    }
    merged_meta = {**base_meta, **extra_keys}
    existing_no_time = {k: v for k, v in existing_meta.items() if k != "imported_at"}
    new_no_time = {k: v for k, v in merged_meta.items() if k != "imported_at"}
    if changed or new_no_time != existing_no_time:
        merged_meta["imported_at"] = now_iso
    else:
        merged_meta["imported_at"] = existing_meta.get("imported_at", now_iso)
    meta_json = json.dumps(merged_meta, indent=2, sort_keys=False) + "\n"
    changed |= sync_text(meta_path, meta_json, context.dry_run)

    status = "imported" if not existing and changed else "updated" if existing and changed else "unchanged"
    return ProcessResult(status=status, suite=suite_readable, test_id=test_id, changed=changed)


def walk_source_files(
    source_root: Path, matcher: IgnoreMatcher, repo_root: Path, max_bytes: int, logger: logging.Logger
) -> Iterable[Tuple[Path, Path] | Tuple[str, Path]]:
    for dirpath, dirnames, filenames in os.walk(source_root):
        current_dir = Path(dirpath)
        filtered_dirs = []
        for d in dirnames:
            subdir = current_dir / d
            rel_subdir = relative_posix(subdir, repo_root)
            if matcher.matches(rel_subdir):
                logger.debug("Skipping directory due to ignore: %s", subdir)
                continue
            filtered_dirs.append(d)
        dirnames[:] = filtered_dirs

        for filename in filenames:
            file_path = current_dir / filename
            rel_file = relative_posix(file_path, repo_root)
            if matcher.matches(rel_file):
                yield ("skip_ignore", file_path)
                continue
            if file_path.suffix.lower() != ".c":
                continue
            try:
                size_bytes = file_path.stat().st_size
            except OSError as exc:
                logger.warning("Unable to stat %s: %s", file_path, exc)
                yield ("error", file_path)
                continue
            if size_bytes > max_bytes:
                yield ("skip_size", file_path)
                continue
            yield (file_path, source_root)


def update_manifest(dest: Path, logger: logging.Logger) -> None:
    cases_dir = dest / "cases"
    suite_counts: Dict[str, int] = {}
    if cases_dir.exists():
        for suite_dir in cases_dir.iterdir():
            if not suite_dir.is_dir():
                continue
            count = 0
            for case_dir in suite_dir.iterdir():
                if (case_dir / "src.c").exists():
                    count += 1
            if count:
                suite_counts[suite_dir.name] = count
    manifest = {
        "version": MANIFEST_VERSION,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_cases": sum(suite_counts.values()),
        "suites": [{"name": name, "count": count} for name, count in sorted(suite_counts.items())],
    }
    manifest_path = dest / "MANIFEST.json"
    content = json.dumps(manifest, indent=2) + "\n"
    write_atomic_text(manifest_path, content)
    logger.info("Updated MANIFEST.json with %d total cases.", manifest["total_cases"])


def update_readme(dest: Path) -> None:
    readme_path = dest / "README.md"
    content = "\n".join(
        [
            "# OpenMP Curated Tests",
            "",
            "This directory aggregates OpenMP-focused C test cases curated for the K Framework C semantics.",
            "",
            "## Structure",
            "",
            "```\n"
            "tests/openmp/\n"
            "  README.md\n"
            "  MANIFEST.json\n"
            "  CITATIONS/\n"
            "    <test_id>.yml\n"
            "  cases/\n"
            "    <suite_name>/\n"
            "      <test_id>/\n"
            "        src.c\n"
            "        LICENSE.txt\n"
            "        META.json\n"
            "        src.in (optional)\n"
            "```\n",
            "",
            "## Discovery Rules",
            "",
            "- Source files must be C (`.c`) and include `omp.h` or contain a `#pragma omp` directive.",
            "- Files larger than the configured size limit are skipped (default 250 KB).",
            "- Patterns from the repository `.gitignore` and `.openmp_k_ignore` are respected.",
            "- Adjacent `.in` files are copied as `src.in` and referenced in metadata.",
            "- License information is copied when available; otherwise, `LICENSE.txt` notes it as unknown.",
            "",
            "## Curator Usage",
            "",
            "1. Run `python curate_openmp_tests.py` and supply source directories when prompted, or pass `--src` flags.",
            "2. The script updates cases idempotently; re-running refreshes modified sources without duplicating entries.",
            "3. Review `MANIFEST.json` and `curation.log` for a summary of actions.",
            "",
            "## Citation Policy",
            "",
            "Every imported case has a matching `CITATIONS/<test_id>.yml` file containing provenance details. Always consult these when referencing the tests in publications or reports.",
            "",
            "## Future Integration",
            "",
            "These curated tests are designed for future automation with K-based runners and OpenMP semantics validation workflows.",
            "",
        ]
    )
    write_atomic_text(readme_path, content)


# ----------------------------
# Main orchestration
# ----------------------------

def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)

    if len(sys.argv) == 1:
        dest_prompt, srcs_prompt = interactive_prompt(DEFAULT_DEST)
        args.dest = str(dest_prompt)
        args.src = [str(p) for p in srcs_prompt]

    dest_path = Path(args.dest).expanduser().resolve()
    dest_path.mkdir(parents=True, exist_ok=True)
    logger = setup_logger(dest_path)

    if not args.src:
        logger.error("No source directories provided. Nothing to do.")
        print("Discovered: 0\nImported new: 0\nUpdated existing: 0\nSkipped by size: 0\nSkipped by ignore: 0\nErrors: 0")
        print(f"Destination: {dest_path}")
        return 0

    src_paths = [Path(src).expanduser().resolve() for src in args.src]
    ignore_matcher = load_ignore_patterns(REPO_ROOT, dest_path)
    max_bytes = max(1, args.max_file_kb) * 1024
    context = CuratorContext(dest=dest_path, collector=args.collector, max_bytes=max_bytes, dry_run=args.dry_run, ignore_matcher=ignore_matcher, logger=logger)

    counts = {
        "discovered": 0,
        "imported": 0,
        "updated": 0,
        "skipped_size": 0,
        "skipped_ignore": 0,
        "skipped_duplicate": 0,
        "errors": 0,
    }

    seen_sources: set[Path] = set()
    futures: List[concurrent.futures.Future[ProcessResult]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=min(8, (os.cpu_count() or 2) * 2)) as executor:
        for src_root in src_paths:
            if not src_root.exists() or not src_root.is_dir():
                logger.error("Source root %s does not exist or is not a directory.", src_root)
                counts["errors"] += 1
                continue

            for item in walk_source_files(src_root, ignore_matcher, REPO_ROOT, max_bytes, logger):
                if isinstance(item, tuple) and len(item) == 2 and isinstance(item[0], str):
                    reason, path = item
                    if reason == "skip_ignore":
                        counts["skipped_ignore"] += 1
                    elif reason == "skip_size":
                        counts["skipped_size"] += 1
                    else:
                        counts["errors"] += 1
                    continue
                candidate_path, root = item  # type: ignore[misc]
                resolved = candidate_path.resolve()
                if resolved in seen_sources:
                    counts["skipped_duplicate"] += 1
                    continue
                seen_sources.add(resolved)
                future = executor.submit(process_candidate, candidate_path, root, context)
                futures.append(future)

        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result.status in {"imported", "updated", "unchanged"}:
                counts["discovered"] += 1
            if result.status == "imported":
                counts["imported"] += 1
            elif result.status == "updated":
                counts["updated"] += 1
            elif result.status == "error":
                counts["errors"] += 1
                if result.error:
                    logger.error("Error processing file: %s", result.error)

    if not args.dry_run:
        update_manifest(dest_path, logger)
        update_readme(dest_path)
    else:
        logger.info("Dry run complete. No files were written.")

    print(f"Discovered: {counts['discovered']}")
    print(f"Imported new: {counts['imported']}")
    print(f"Updated existing: {counts['updated']}")
    print(f"Skipped by size: {counts['skipped_size']}")
    print(f"Skipped by ignore: {counts['skipped_ignore']}")
    print(f"Skipped duplicates: {counts['skipped_duplicate']}")
    print(f"Errors: {counts['errors']}")
    print(f"Destination: {dest_path}")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\nCurator interrupted by user.")
        sys.exit(0)


"""
Sample Interactive Session
--------------------------
$ python curate_openmp_tests.py
Enter one or more source roots that contain OpenMP examples. Paste absolute paths, one per line. Press Enter on a blank line to finish.
/data/openmp-examples
/home/user/benchmarks/openmp

Discovered: 14
Imported new: 12
Updated existing: 2
Skipped by size: 3
Skipped by ignore: 1
Errors: 0
Destination: /path/to/repo/tests/openmp

Resulting Directory Tree (excerpt)
----------------------------------
tests/openmp/
  README.md
  MANIFEST.json
  curation.log
  CITATIONS/
    parallel_for_1234567.yml
  cases/
    openmp_examples/
      parallel_for_1234567/
        src.c
        src.in
        LICENSE.txt
        META.json
"""
