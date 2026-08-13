# ReFuncTion

A research prototype static analyzer for C programs, proving conditional
**termination**, **non-termination**, **termination resilience**, **CTL** and
**ATL** properties — the latter on *open* programs, where inputs are controlled
by a coalition of agents and by an adversary.

It infers piecewise-defined ranking functions and sufficient preconditions by
abstract interpretation. It answers **TRUE** when it proves the property,
**UNKNOWN** otherwise: sound but incomplete.

## Installation

APRON binds to GMP/MPFR and the C frontend (mopsa) to libclang:

```
sudo apt-get install libgmp-dev libmpfr-dev m4 pkg-config \
                     clang libclang-cpp-dev libclang-dev llvm-dev
```

Then, with [opam](https://opam.ocaml.org/doc/Install.html) and OCaml >= 4.14:

```
opam install . --deps-only
dune build                        # produces main.exe
```

> **dune must be < 3.21**: mopsa 1.2 does not build with newer versions. The
> bound is in `function.opam`; if your switch has a newer dune, run
> `opam install 'dune<3.21'` first.

## Usage

```
./main.exe <file> <analysis> [options]
```

| Analysis | Invocation |
|---|---|
| Termination / non-termination | `-termination` · `-nontermination` |
| Termination resilience | `-resilience` |
| Guarantee / recurrence | `-guarantee <file>` · `-recurrence <file>` |
| CTL | `-ctl "AF{exit:true}"` |
| ATL | `-atl "<p1,p2>F{gain == 1}"` |

Main options (`./main.exe -help` for the rest):

```
-domain boxes|octagons|polyhedra   abstract domain (default boxes)
-joinbwd 2                         widening delay, backward analysis
-ordinals 2                        maximum ordinal for ranking functions
-refine                            restrict the backward analysis to reachable states
-precondition "x == 1"             assumed at the program entry
-config <file.json>                read the configuration from JSON
-vulnerability                     report the variables that could falsify the property
```

For ATL, inputs are attributed to agents with `input("agent", lo, hi)`, and
`<p1,p2>F{...}` asks whether that coalition can force the goal whatever the
others do.

## Benchmarks

`tests/` holds the benchmarks, one `.json` configuration next to each `.c`
declaring the analysis, the property and the expected result — grouped by
`termination`, `ctl`, `atl`, `guarantee`, `recurrence`, `vulnerability`.

The test tooling is in [`script/`](script/README.md), with the day-to-day
commands in [script/WORKFLOW.md](script/WORKFLOW.md):

```
script/harness.py run -o regression_out --layout flat --cover logs
python3 script/function-diff.py logs regression_out --regression --ignore-time
```

Both run in CI on every push.

## Docker

```
docker build -t function .
docker run -it function
```
