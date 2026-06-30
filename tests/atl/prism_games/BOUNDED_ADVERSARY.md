# De-probabilising reachability: the adversary-chosen finite bound

This note explains a modelling choice used by the **reachability** (`F`)
benchmarks in this suite, and why it is done the way it is. It is meant to
pre-empt a reviewer objection.

## The mismatch

The PRISM(-games) originals are quantitative: a failure happens "with
probability `p < 1`", and the property of interest is **almost-sure**
reachability, `P_max[F target] = 1`. With i.i.d. failures of probability
`p < 1`, "fail forever" has probability 0, so the target is reached with
probability 1.

Our setting (FuncTion / ATL) is a **two-player worst-case** game, with no
probabilities. The natural de-probabilisation "failure occurs with prob `p`"
↦ "the adversary *may* fail" is **unsound for reachability**: an unrestricted
adversary simply fails every round, so `<coalition> F target` is FALSE. The
worst-case reading loses the almost-sure guarantee.

(For **safety** properties, `G`, there is no such problem: `P_max[G safe] = 1`
holds iff the coalition can enforce `safe` against *every* adversary move, which
is exactly the worst-case game semantics. So the safety benchmarks here use a
plain unrestricted adversary and need none of the machinery below.)

## The principled fix we cannot use

The sound qualitative abstraction of almost-sure reachability is reachability
**under a fairness assumption**: `P_max[F T] = 1` iff the coalition reaches `T`
under all *fair* resolutions of the adversary (the adversary may not block
forever while progress is enabled). FuncTion's ATL/CTL iterators do **not**
support fairness assumptions, so we cannot state this directly.

## What we do instead, and how it is kept honest

We restrict the adversary to a **finite number of failures** -- the closest
sound surrogate for "fail only finitely often". Crucially, the bound is

  * **not fixed in advance**: it is chosen by the adversary at the start of the
    run, e.g. `int budget = input("env");`. The integer domain is unbounded, so
    the adversary may pick any finite value, arbitrarily large, but never ∞.
  * therefore the property must be proved **for every finite bound**, i.e. the
    well-founded order (ranking function) must be synthesised by the tool, not
    handed to it as a hard-coded constant such as `3`.

This is the weakest restriction that recovers the expected TRUE verdict while
remaining a genuine proof obligation for FuncTion.

### The reachability target is also parametric

For the count-goal reachability benchmarks the *target* (file size, team size,
consensus size, goal distance) is likewise **adversary-chosen and not fixed**
(e.g. `int chunks = input("env"); ... <snd>F{delivered >= chunks}`). So no
magic constant survives on either side: the property must hold for any instance
size AND any finite number of failures. The two binary/bounded-target
exceptions are `zeroconf` (goal is `configured == 1`, no count) and `future_mi`
(target is exactly the ceiling, `gain >= cap`, with cap itself market-chosen --
the "force the maximal profit" reading; it must equal cap, not exceed it, so the
UNKNOWN stays "not guaranteeable" rather than "structurally impossible").

## Honest limitations (state these in the thesis)

1. It still injects an auxiliary counter: the well-founded order is carried by a
   variable that is not in the original model. Without fairness support this is
   unavoidable -- but the counter's bound is adversarial/unbounded, not magic.
2. A finite (even if unbounded) budget is *strictly stronger* than fairness:
   fairness also forbids "infinitely often" without an a-priori finite cap.
   Both give the same verdict for these reachability targets, but they are not
   equal restrictions.
3. The verdict is **robust to the bound's value** (TRUE for any finite budget),
   so these are best read as *qualitative* benchmarks ("reachable under a
   finite-failure / progress assumption"), not as an exact rendering of
   `P_max[F target] = 1`.

## Which benchmarks use this

Reachability (`F`) models, all with an adversary-chosen finite bound:
`bounded_retransmission`, `zeroconf`, `collective_decision`,
`autonomous_driving` (reach), `vehicle_control_hostile` (reach),
`future_mi` (the `bars` budget).

Safety (`G`) models use a plain unrestricted adversary (no bound):
`intrusion_detection`, `microgrid`, `aircraft_power`, `self_adaptive`,
`dns_amplification`, `dos_quantification`, `rfid_attack_defence`,
`kaminsky_dns`, `network_virus`, `non_repudiation`, `asw_fair_exchange`,
`embedded_control`, `workstation_cluster`, plus the safety halves of the
vehicle/driving/navigation pairs.
