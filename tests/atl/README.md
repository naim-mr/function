# ATL benchmarks for FuncTion

State-of-the-art ATL examples transcribed to numeric C for the FuncTion
strategic analysis. Each example uses the input-agent convention:

* every move of an agent is a call `input("<agent>")` (unbounded, nondeterministic);
* the coalition `<a,b,...>` in the property selects the **controllable (angelic)**
  agents; all other agents are **adversarial (demonic)**.

Run an example with the property given in its header comment / `.json`, e.g.

```
./main.exe -domain polyhedra tests/atl/stv/castles.c -atl "<att>F{hp2 == 0}"
```

Each example ships three files: `<name>.c` (the FuncTion encoding),
`<name>.json` (the property), and an original-source file (verbatim when one
exists, otherwise the formal model from the source paper with full citation).

## Layout (by source)

### `classic/` — foundational ATL examples
| File | Source | Property | Expected |
|------|--------|----------|----------|
| train_gate | Alur/Henzinger/Kupferman, JACM'02 (Example 2.2) | `<train,ctr>F{s == 3}` | TRUE (`<train>` alone: UNKNOWN) |
| robots_carriage | Demri/Goranko/Lange, *Temporal Logics in CS* 2016, Ch. 9 | `<r1,r2>F{pos == 1}` | TRUE (single robot: UNKNOWN) |
| matching_pennies | Osborne/Rubinstein, *A Course in Game Theory* 1994, Ex. 17.1 | `<m>F{win == 1}` | UNKNOWN (`<m,h>`: TRUE) |
| nim | classic game | `<me>F{win == 0}` | TRUE (N=7) |

### `stv/` — STV scalability benchmarks (ATL_ir)
Repo: https://github.com/blackbat13/stv · paper: https://arxiv.org/pdf/1612.02684
| File | Property | Expected |
|------|----------|----------|
| castles | `<att>F{hp2 == 0}` | TRUE |
| tianji | `<tj>F{wins >= 2}` | TRUE |
| bridge_end | `<decl>F{tricks >= 2}` | TRUE (numeric simplification) |
| drones | `<d1,d2>G{p <= 5}` | TRUE |
| machines_robots | `<r1,r2>F{produced >= 4}` | TRUE |

### `syntcomp/` — reactive synthesis (controller vs environment)
Repo: https://github.com/SYNTCOMP/benchmarks (originals are **verbatim** TLSF)
| File | Property | Expected |
|------|----------|----------|
| round_robin_arbiter | `<arb>G{g1 + g2 <= 1}` | TRUE |
| simple_arbiter | `<arb>G{g1 + g2 <= 1}` | TRUE |
| prioritized_arbiter | `<arb>G{g1 + g2 + gm <= 1}` | TRUE |
| load_balancer | `<lb>G{g1 + g2 <= 1}` | TRUE |

### `prism_games/` — applied case studies (rPATL, de-probabilised)
Repo: https://www.prismmodelchecker.org/games/
| File | Property | Expected |
|------|----------|----------|
| robot_coordination | `<r1,r2>F{x1 >= 4}` | TRUE |
| microgrid | `<ctrl>G{load <= 3}` | TRUE |
| task_graph | `<sched>F{done == 1}` | TRUE |
| intrusion_detection | `<def>G{compromised == 0}` | TRUE |

These drop the probability/reward dimension of the original rPATL specs and
keep the strategic (reachability/safety) core — see each `.txt`.

### `mcmas/` — epistemic benchmarks
Mostly temporal-**epistemic** (knowledge `K_a`), not numerically transcribable.
Only the strategic core is provided; see [mcmas/README.md](mcmas/README.md).
| File | Property | Note |
|------|----------|------|
| bit_transmission | `<sender,chan>F{ack == 1}` | epistemic part dropped |

## Enriched ATL properties (nested / Until / coalition alternation)

Beyond the flat `F{p}` / `G{p}` queries above, these extra `.json` files put
**genuinely strategic** properties (nested strategic operators, strategic
Until, coalition alternation, negation of an opponent's ability) on the same
models. Each carries an `expected` field used as an oracle.

| File | Property | Kind | Expected |
|------|----------|------|----------|
| classic/train_gate.recurrence | `<ctr>G{<ctr>F{s == 0}}` | controllable recovery | TRUE |
| classic/train_gate.single | `<train>F{s == 3}` | soundness (no strategy) | UNKNOWN |
| classic/robots_carriage.stabilize | `<r1,r2>F{<r1,r2>G{pos == 1}}` | stabilization (F-G) | TRUE |
| classic/robots_carriage.single | `<r1>F{pos == 1}` | soundness (no strategy) | UNKNOWN |
| classic/matching_pennies.coalition | `<m,h>F{win == 1}` | ATL/CTL gap (coalition) | TRUE |
| stv/castles.until | `<att>U{hp1 > 0}{hp2 == 0}` | reach-while-avoid | TRUE |
| stv/castles.denial | `<att>F{NOT{<def>F{hp1 == 0}}}` | coalition alternation + denial | TRUE |
| stv/drones.stabilize | `<d1,d2>F{<d1,d2>G{p == 0}}` | stabilization (F-G) | TRUE |
| stv/drones.single | `<d1>G{p <= 5}` | soundness (no strategy) | UNKNOWN |
| syntcomp/round_robin_arbiter.recurrence | `<arb>G{<arb>F{g1 == 1}}` | controllable recurrence | TRUE |
| prism_games/microgrid.maintain | `<ctrl>G{AND{load <= 3}{<ctrl>F{load == 0}}}` | invariant + nested liveness | TRUE |
| prism_games/intrusion_detection.recover | `<def>G{<def>F{exposure == 0}}` | controllable recovery | TRUE |

The `*.single.json` cases are **soundness witnesses**: they must NOT be
reported TRUE (no winning strategy exists). The nested `G{<>F{...}}` cases
are the ones a CTL-controlled analysis cannot capture.

## References

* Alur, Henzinger, Kupferman. *Alternating-Time Temporal Logic*, JACM 2002 — https://www.cis.upenn.edu/~alur/Jacm02.pdf
* Demri, Goranko, Lange. *Temporal Logics in Computer Science*, Cambridge Univ. Press, 2016 — Ch. 9 (robots & carriage)
* Bulling, Goranko, Jamroga. *Logics for Reasoning about Strategic Abilities* — https://home.ipipan.waw.pl/w.jamroga/papers/satol15.pdf
* Jamroga, Kurpiewski et al. STV — https://github.com/blackbat13/stv ; *Fixpoint Approximation...* — https://arxiv.org/pdf/1612.02684
* SYNTCOMP benchmark library — https://github.com/SYNTCOMP/benchmarks
* PRISM-games — https://www.prismmodelchecker.org/games/
* MCMAS — https://link.springer.com/article/10.1007/s10009-015-0378-x
