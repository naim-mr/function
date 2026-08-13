# script/ — test tooling

## NAME

`harness.py` — run benchmarks, check coverage, promote references, compare runs
`function-diff.py` — compare two report trees (vendored from MOPSA)
`runtest.py` — render HTML / LaTeX / CSV reports

`runtest.py` builds on `harness.py`: there is one definition of how a benchmark
is invoked.

## SYNOPSIS

    script/harness.py run     [-e EXEC] [-o OUT] [-g GROUPS] [-f RE] [-t SEC] [-j N]
                              [--layout isolated|flat] [--cover REF] [--all]
                              [--short] [--report-flags] [--force "OPTS"]
                              [--tol-suff N] [--tol-leaves N] [--tol-time F]
                              [--strict-time]
    script/harness.py cover   REF OUT
    script/harness.py bless   RUN.run.json [--fields F,...] [-n]
    script/harness.py promote RUN_DIR [--ref logs] [-f RE] [-n]
    script/harness.py compare A.run.json B.run.json [--gate verdicts|suff|none]
                              [--list N] [--csv FILE]

    python3 script/function-diff.py REF OUT [--regression] [--ignore-time] [--summary]

    script/runtest.py [--html] [--latex] [--csv] [-f RE] [-j N] [--short]

## COMMANDS

**run** — runs every discovered benchmark, writes one report per test plus a
summary `<OUT>.run.json` (a sibling of the tree, never inside it). Exits non-zero
on unexpected failures, missing coverage, or `expected` mismatches.

**cover** — checks an existing run directory against a reference: every baseline
in REF must have been reproduced.

**bless** — writes a run's observed values into each test config's `expected`.
Refuses failed and timed-out tests; skips shared matrix configs.

**promote** — copies a run's reports into the reference directory (`logs/`).
Never deletes a baseline the run did not reproduce.

**compare** — puts two runs side by side: verdict movements, `suff`/`leaves`
deltas, time factor, coverage. Precision and time are measured only over tests
decided on both sides.

## OPTIONS

`-g, --groups`   comma-separated groups; default is every subdirectory of `tests/`
`-f, --filter`   regex on the test path
`-t, --timeout`  per-test seconds; a config's own `timeout` overrides it
`--layout flat`  write reports in the layout of `logs/`; required to diff against it
`--cover REF`    check coverage against REF **and** restrict the run to baselined tests
`--all`          with `--cover`, run everything instead
`--short`        prune the large SV-COMP subtrees
`--report-flags` add `-domain polyhedra -refine -ordinals 3 -joinbwd 7`
`--force "OPTS"` analyzer options forced on every test
`--tol-*`        allowed drift on the pinned `suff` / `leaves` (absolute) and `time` (factor)

## TEST CONFIGURATION

Each `tests/**/<name>.json` may declare what is expected of it:

    "expected": "TRUE"
    "expected": { "result": "TRUE", "suff": 3, "leaves": 7, "time": 1.23 }
    "expected": { "status": "FAIL", "reason": "break unsupported" }

Every field is optional; only what is pinned is checked.

| field | meaning | comparison | fails the run |
|---|---|---|---|
| `result` | verdict `TRUE`/`UNKNOWN` | exact | yes |
| `suff` | defined leaves = sufficient preconditions found | absolute drift | yes |
| `leaves` | total leaves = tree size | absolute drift | yes |
| `time` | seconds, wall-clock | factor (×3) | no, unless `--strict-time` |
| `status` | `OK`/`FAIL`/`TO` | exact | yes |

Documentation keys carried alongside, never compared, preserved by `bless`:
`reason`, `issue`, `pending`. `pending` marks a knowingly-degraded verdict:
promote it into `logs/` so CI is green, and the note keeps it visible in every
run. A malformed config is reported and fails the run — it used to fall back to
`{}` in silence, running the test with no property at all.

Tolerances are global (CLI), not per test. A pinned `"status": "FAIL"` declares a
known failure: it stops failing the run and its baseline is exempt from the
coverage check, but it is reported if the test starts passing again.

Other config keys: `analysis`, `property`, `domain`, `precondition`, `timeout`.

## WORKFLOWS

Regression:

    script/harness.py run -o regression_out --layout flat --cover logs
    python3 script/function-diff.py logs regression_out --regression --ignore-time

Accepting a new behaviour — both references must be updated:

    script/harness.py promote regression_out -f <test>      # logs/
    script/harness.py bless regression_out.run.json -f <test>  # configs

Ablation:

    script/harness.py run --force "-max-partitions 4" -o run_k4
    script/harness.py run --force "-max-partitions 8" -o run_k8
    script/harness.py compare run_k4.run.json run_k8.run.json --csv sweep.csv

## NOTES

- The two front-ends invoke the analyzer differently on purpose: `runtest.py`
  adds `REPORT_FLAGS`, the regression uses a bare `-config`, as `logs/` was
  produced. The analyzer encodes its options in the report filename, so mixing
  them makes every baseline path miss.
- Option order carries precedence: `--report-flags` goes before `-config` (the
  test config may override it), `--force` after (it wins).
- Discovery reads the filesystem, not a group table; coverage is computed from
  the baselines, not from discovery. Both directions are required to detect a
  whole group being skipped.
- Without `--cover`, discovery yields ~223k (test, config) pairs: the resilience
  matrix crosses every `.c` of its subtree with every root property.
- `time` is wall-clock; the analyzer's own figure is quantised to one second.
- Shared matrix configs (`tests/atl/resilience/*.json`) cannot carry `expected`:
  one config, thousands of sources.
- `runtest.py` overwrites `results/stats.csv` with the scope of the run.

## CI

`.github/workflows/ci.yml` — build and regression, both gating
(`REGRESSION_GATE`). The gate fails on ANY drift from `logs/`, improvements
included: `function-diff`'s `is_regressed` counts `new_success` too, so a test
that starts passing blocks until it is entered with `promote`. Declared
failures (`status: FAIL`) and accepted regressions (`pending`) do not block.
`.github/workflows/regression-report.yml` — weekly full run; keeps a single
drift issue up to date, closes it when the baseline is green.

## FILES

| | |
|---|---|
| `logs/` | reference reports (versioned) |
| `regression_out/`, `*.run.json` | run output (git-ignored) |
| `logs.bash` | historical loop that produced `logs/`; kept for reference |
| `generate.py`, `clean_subset.py`, `lift_ctl.py` | benchmark generation and transformation |
