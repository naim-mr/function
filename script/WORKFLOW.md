# Workflow

Day-to-day use of the test tooling. Reference: [README.md](README.md).

## Every change

```bash
dune build
script/harness.py run -o regression_out --layout flat --cover logs
python3 script/function-diff.py logs regression_out --regression --ignore-time
```

Both must exit 0. `run` covers unexpected failures, baseline coverage and the
values pinned in the configs' `expected`; `function-diff` covers any drift from
the reports in `logs/`. This is exactly what CI runs, so green locally means
green online.

## When a verdict changes

| Situation | Action |
|---|---|
| Improvement | `promote` + `bless` the test — otherwise CI blocks |
| Regression you fix | fix it, promote nothing |
| Regression you accept | `promote` + `bless`, and add `pending` / `issue` to the config |

Always scope with `-f`, never in bulk: accepting a change of behaviour is a
per-test judgement.

```bash
script/harness.py promote regression_out -f <test> -n   # review first
script/harness.py promote regression_out -f <test>      # logs/
script/harness.py bless regression_out.run.json -f <test>   # configs
```

Both references must be updated. `bless` alone leaves `function-diff` red;
`promote` alone loses the record of why the verdict was accepted.

An accepted regression is documented in its config:

```json
"expected": {
  "result": "UNKNOWN",
  "pending": "why this is degraded",
  "issue": "#42"
}
```

`result` stays checked, so the test is reported the day it changes again.

## When a test cannot pass

A known bug, not a verdict to accept:

```json
"expected": { "status": "FAIL", "reason": "break unsupported in backward analysis" }
```

It stops blocking the run and its baseline is exempt from the coverage check,
but it is reported if it ever starts passing.

## Order matters

Commit the code, re-run, *then* `promote` / `bless`. A reference frozen from a
dirty tree corresponds to no commit — `run.json` stamps `-dirty` as a reminder.

## Ablations

```bash
script/harness.py run --force "-max-partitions 4" -o run_k4
script/harness.py run --force "-max-partitions 8" -o run_k8
script/harness.py compare run_k4.run.json run_k8.run.json --csv sweep.csv
```

`--force` applies after `-config`, so it overrides the test's own config: the
ablation is a property of the run, not of any test. `--csv` appends one
aggregate row per ablation point — the paper's sweep table.

## Refactors (J1 and after)

The baseline is green today, so the criterion is simply: after the refactor,
both commands above still exit 0. If a verdict moves, it is the refactor.
