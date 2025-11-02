# OpenMP Curated Tests

This directory aggregates OpenMP-focused C test cases curated for the K Framework C semantics.

## Structure

```
tests/openmp/
  README.md
  MANIFEST.json
  CITATIONS/
    <test_id>.yml
  cases/
    <suite_name>/
      <test_id>/
        src.c
        LICENSE.txt
        META.json
        src.in (optional)
```


## Discovery Rules

- Source files must be C (`.c`) and include `omp.h` or contain a `#pragma omp` directive.
- Files larger than the configured size limit are skipped (default 250 KB).
- Patterns from the repository `.gitignore` and `.openmp_k_ignore` are respected.
- Adjacent `.in` files are copied as `src.in` and referenced in metadata.
- Project-specific quoted headers (for example, `"ompvv.h"`) are copied alongside the test when they are found in the source tree; their names appear under `support_headers` in `META.json`.
- License information is copied when available; otherwise, `LICENSE.txt` notes it as unknown.

## Curator Usage

1. Run `python curate_openmp_tests.py` and supply source directories when prompted, or pass `--src` flags.
2. The script updates cases idempotently; re-running refreshes modified sources without duplicating entries.
3. Review `MANIFEST.json` and `curation.log` for a summary of actions.

## Citation Policy

Every imported case has a matching `CITATIONS/<test_id>.yml` file containing provenance details. Always consult these when referencing the tests in publications or reports.

## Future Integration

These curated tests are designed for future automation with K-based runners and OpenMP semantics validation workflows.
