#!/usr/bin/env python3
import argparse
import subprocess
import sys
import shlex
from pathlib import Path
import shutil
import re
import os
from datetime import datetime



# .tmp-<seq>-<seq> up to whitespace/quotes/angle-brackets
TMP_PATTERN = re.compile(r"\.tmp-[^\s'\"<>]+-[^\s'\"<>]+")
# Flexible JSON=/UUID= extractors: '...', "...", or unquoted up to whitespace
JSON_RE = re.compile(r"\bJSON (?:'([^']*)'|\"([^\"]*)\"|(\S+))")
UUID_RE = re.compile(r"\bUUID (?:'([^']*)'|\"([^\"]*)\"|(\S+))")

def _last_token(regex, text):
    """Return the last matched value for regex with 3 alt groups."""
    last = None
    for m in regex.finditer(text):
        val = m.group(1) or m.group(2) or m.group(3)
        if val is not None:
            last = val
    return last

def main():
    ap = argparse.ArgumentParser(
        description="Run dist/kcc on a C file, print last .tmp-*-*, JSON/UUID flags, and the 'kast-txt-*' file inside the derived directory."
    )
    ap.add_argument("cfile", help="C source file (with or without .c)")
    ap.add_argument("depth", help="krun search depth")
    args = ap.parse_args()
        
    
    src = Path(args.cfile)

    if src.suffix != ".c":
        src = src.with_suffix(".c")
    if not src.exists():
        print("error: source file not found: {}".format(src), file=sys.stderr)
        sys.exit(1)
    if args.depth == None:
        print("depth not specified")
        sys.exit(1)
    else:
        try:
            if int(str(args.depth)) < 0:
                raise Exception
        except Exception:
            print("invlaid depth")
            sys.exit(1)
            
    depth = str(args.depth)

    # Prefer ./dist/kcc; else PATH
    kcc = Path("dist") / "kcc"
    if not kcc.exists():
        found = shutil.which("kcc")
        if not found:
            print("error: could not find 'dist/kcc' or 'kcc' in PATH", file=sys.stderr)
            sys.exit(1)
        kcc = Path(found)

    out_stem = src.stem
    cmd = [str(kcc), str(src), "-d", "-ftranslation-depth", depth, "-o", out_stem]

    try:
        proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,  # == text=True on 3.7+
        )
    except FileNotFoundError:
        print("error: compiler not found: {}".format(kcc), file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(130)

    combined = (proc.stdout or "") + "\n" + (proc.stderr or "")
    # print (combined)
    # (1) Last .tmp-*-*
    last_tmp = None
    for m in TMP_PATTERN.finditer(combined):
        last_tmp = m.group(0)
    if last_tmp:
        print(last_tmp)

    # (2) Last JSON=... and UUID=... anywhere in output
    last_json = _last_token(JSON_RE, combined)
    last_uuid = _last_token(UUID_RE, combined)
    if last_json is not None:
        print("JSON='{}'".format(last_json))
        last_json = "{}".format(last_json)
    if last_uuid is not None:
        print("UUID='{}'".format(last_uuid))
        last_uuid = "{}".format(last_uuid)

    # (3) From last_tmp, split on '/' and keep the first element
    kast_dir = None
    if last_tmp:
        first_component = last_tmp.split('/', 1)[0]  # keep the first piece only
        # Interpret as a directory relative to current working directory
        tmp_dir = Path(first_component)
        if tmp_dir.is_dir():
            # Find files starting with "kast-txt-"
            try:
                candidates = [p for p in tmp_dir.iterdir()
                              if p.is_file() and p.name.startswith("kast-txt-")]
            except OSError as e:
                print("error: cannot list directory {}: {}".format(tmp_dir, e), file=sys.stderr)
                candidates = []

            if candidates:
                # Pick the most recently modified
                candidates.sort(key=lambda p: p.stat().st_mtime, reverse=True)
                print(str(candidates[0]))
                kast_dir = str(candidates[0])
        else:
            # Helpful hint if directory missing
            print("warning: derived directory not found: {}".format(tmp_dir), file=sys.stderr)

    # If we found none of the requested tokens, surface output to help debug
    if not last_tmp and last_json is None and last_uuid is None:
        print("error: no '.tmp-*-*', JSON=, UUID=, or 'kast-txt-*' found", file=sys.stderr)
        if combined.strip():
            print("\n--- compiler output ---\n" + combined, file=sys.stderr)
        # If kcc failed, propagate its code; else return 2 to indicate “not found”
        rc = proc.returncode if proc.returncode != 0 else 2
        sys.exit(rc)

    # krun_cmd = [
    #         "krun", kast_dir,
    #         "--directory", "./dist/profiles/x86-gcc-limited-libc/c-translation-kompiled",
    #         "--output", "pretty",
    #         "--output-file", "output-100-steps.txt",
    #         "--depth", "100",
    #         "--parser", "''cat''",
    #         "--config-parser", "OPTIONS=\"echo\"",
    #         "--config-parser", "JSON=\"echo\"",
    #         "--config-parser", "UUID=\"echo\"",
    #         "-c", "OPTIONS='`.Set`(.KList)'",
    #         "-c", "JSON=" + '{}'.format(last_json) ,
    #         "-c", "UUID=" + '{}'.format(last_uuid),
    #     ]
    timestamp = datetime.now().strftime("%Y%m%d%H%M")
    output_dir = "experiments/translation-" + args.cfile
    Path(output_dir).mkdir(exist_ok=True)

    depth_flag = "" if depth == 0 else f"--depth {depth} "

    krun_cmd = (
        "krun {kast_dir} "
        "--directory ./dist/profiles/x86-gcc-limited-libc/c-translation-kompiled "
        "--output pretty "
#        "--output-file {output_dir}/output-{ut}-{cf}-{depth_}.txt "
        "--output-file {output_dir}/trans-{cf}-{depth_}.txt "
        "{depth_flag}"
        "--parser \"cat\" "
        "--config-parser OPTIONS=\"echo\" "
        "--config-parser JSON=\"echo\" "
        "--config-parser UUID=\"echo\" "
        "-c 'OPTIONS=`.Set`(.KList)' "
        "-c JSON='{json}' "
        "-c UUID='{uuid}'"
    ).format(
        kast_dir=shlex.quote(kast_dir),
        output_dir = output_dir,
#        ut=timestamp,
        cf=args.cfile,
        depth_=depth,
        depth_flag=depth_flag,
        json=last_json,
        uuid=last_uuid,
    )
    
    
    subprocess.run(krun_cmd, shell=True, executable="/bin/bash")
    sys.exit(0)

if __name__ == "__main__":
    main()
