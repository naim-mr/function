# PRISM / PRISM-games case studies NOT imported

Scope: case studies from the PRISM-games page
(<https://www.prismmodelchecker.org/games/casestudies.php>) and the full PRISM
index (<https://www.prismmodelchecker.org/casestudies/index.php>).

Everything **imported** lives in the sibling folders, organised by the PRISM
index categories: `Security/`, `Planning_synthesis/`, `game_theory/`,
`Power_management/`, `Communication_protocols/`, `Performance_reliability/`.
Each imported case = a `.c` model + `.txt` correspondence note + `.json`
property. The list below is what we deliberately left out, with a reason.

## Why a case is excluded -- reason codes

- **[SIM]**  Essentially simultaneous-move (concurrent) game. Our C encoding
  reads `input()` sequentially, which imposes a move order: one player "sees"
  the other's current move. For these games the simultaneity *is* the game
  (the second mover wins), so a sequential encoding flips the result.
- **[NO-CTRL]**  Pure stochastic model (CTMC/DTMC) with no controllable
  decision-maker. There is no one to put in the coalition; making it a game
  would mean *inventing* a controller that does not exist in the model.
- **[VERIF]**  Symmetric randomised distributed algorithm: the question is
  "for all schedulers", not "does a coalition have a winning strategy". No
  adversarial coalition split, so strategic ATL adds nothing.
- **[INFO]**  Objective is information-theoretic (anonymity / secrecy), not a
  reachability/safety objective expressible as `<C>F/G {...}`.
- **[EQUI]**  Non-zero-sum equilibrium game: the opponent is *rational /
  self-interested*, not hostile. Cast as a pure adversary in ATL the model
  collapses (the adversary just refuses everything).
- **[POMDP]**  Partial observability. Our ATL/FuncTion semantics is perfect
  information; the coalition would "see" hidden state -> unfaithfully optimistic.
- **[REDUND]**  Cleanly castable, but structurally identical to a case already
  imported; would add a duplicate, not a new benchmark.
- **[UNSURE]**  Castable in principle, but the faithful expected result or the
  protocol details are not certain enough to meet the 100%-certainty bar.

---

## PRISM-games page (the concurrent / CSG ones)

| Case study | Type | Code | Reason |
|---|---|---|---|
| Jamming multi-channel radio | CSG | [SIM] | Whoever picks the channel knowing the other's pick wins -- pure simultaneity. |
| Power control in cellular networks | CSG | [SIM] | Concurrent power-level choices + equilibrium reasoning. |
| Public good game | CSG | [SIM]/[EQUI] | Simultaneous contributions resolved by Nash/correlated equilibria. |
| Aloha protocol | CSG | [SIM] | Collisions are exactly two stations transmitting at the same time. |
| Trust models for user-centric networks | SMG/CSG | [SIM] | Mixed model whose decisive part is concurrent. |

## Randomised Distributed Algorithms

| Case study | Code | Reason |
|---|---|---|
| Self-stabilising algorithms (Herman / Israeli-Jalfon / Beauquier) | [VERIF] | Convergence under any scheduler; no adversarial coalition. |
| Two-process wait-free test-and-set (Tromp-Vitanyi) | [VERIF] | All-schedulers verification, no winning coalition. |
| Synchronous leader election (Itai-Rodeh) | [VERIF] | Symmetric randomised; no coalition to control. |
| Asynchronous leader election (Itai-Rodeh) | [VERIF] | Idem. |
| Dining philosophers (Lehmann-Rabin) | [VERIF] | Liveness under fair scheduler; no coalition. |
| Dining philosophers (Lynch-Saias-Segala) | [VERIF] | Idem. |
| Dining cryptographers (Chaum) | [INFO] | Anonymity, not reachability/safety. |
| Randomised mutual exclusion (Rabin) | [VERIF] | All-schedulers property. |
| Randomised mutual exclusion (Pnueli-Zuck) | [VERIF] | Idem. |
| Randomised consensus (Aspnes-Herlihy) | [VERIF] | Symmetric; no coalition (cf. Byzantine below). |
| Randomised shared coin (Aspnes-Herlihy) | [VERIF] | Idem. |
| Byzantine agreement (Cachin-Kursawe-Shoup) | [SIM]+[UNSURE] | Quasi-simultaneous broadcast rounds, and fidelity needs the n>3f threshold + multi-round message passing -- otherwise trivial/wrong. |
| Rabin's choice coordination | [VERIF] | Symmetric randomised coordination. |
| Dice programs (Knuth-Yao) | [NO-CTRL] | Pure probabilistic program, no agent. |

## Communication, Network and Multimedia Protocols

(imported: `bounded_retransmission`, `zeroconf`)

| Case study | Code | Reason |
|---|---|---|
| Bluetooth device discovery | [SIM] | Discovery driven by simultaneous clock/frequency hopping; no clean controller. |
| IEEE 802.3 CSMA/CD | [SIM] | Collisions = simultaneous transmissions. |
| IEEE 1394 FireWire root contention | [SIM] | Root contention is a symmetric simultaneous race. |
| IEEE 802.11 wireless LAN | [SIM] | Backoff/contention is simultaneous. |
| IEEE 802.15.4 CSMA-CA (ZigBee) | [SIM] | Contention is simultaneous. |
| Probabilistic broadcast protocols | [NO-CTRL] | Epidemic spreading, no decision-maker. |
| Gossip protocol | [NO-CTRL] | Epidemic spreading, no decision-maker. |

## Security

(imported: `non_repudiation`, `dns_amplification`, `rfid_attack_defence`,
`intrusion_detection`, `asw_fair_exchange`, `network_virus`, `kaminsky_dns`,
`dos_quantification`)

| Case study | Code | Reason |
|---|---|---|
| Contract signing (Even-Goldreich-Lempel) | [REDUND] | Fair-exchange family, already represented by `asw_fair_exchange` / `non_repudiation`. |
| Contract signing (Ben-Or-Goldreich-Micali-Rivest) | [REDUND] | Idem. |
| Probabilistic fair exchange (Rabin) | [REDUND] | Idem. |
| Non-repudiation protocols (generic) | [REDUND] | Already imported `non_repudiation`. |
| Crowds protocol (Reiter-Rubin) | [INFO] | Sender anonymity, not reachability. |
| Dining cryptographers (anonymity) | [INFO] | Anonymity. |
| Crowds / Adithia / Onion routing / Tarzan | [INFO] | Anonymity. |
| Anonymity network topologies | [INFO] | Anonymity. |
| PIN cracking schemes | [UNSURE] | Probabilistic guessing; no clean strategic reach/safety property. |
| PIN block attacks | [UNSURE] | Idem. |
| Quantum cryptography (BB84 / B92) | [INFO] | Quantum secrecy, info-theoretic, out of paradigm. |
| Reinforcement model for collaborative security | [UNSURE] | Model under-specified for a faithful game cast. |
| Certified e-mail protocol (mobile) | [REDUND]+[UNSURE] | Fair-exchange family already covered; protocol details uncertain. |
| Needham-Schroeder / TMN | [INFO] | Authentication/secrecy goal, not a coalition reachability game. |
| SSL handshake (mobile) | [NO-CTRL] | Performance/secrecy study, no strategic game. |

## Biology

| Case study | Code | Reason |
|---|---|---|
| Cell cycle control in Eukaryotes | [NO-CTRL] | Reaction-kinetics CTMC, no decision-maker. |
| FGF signalling | [NO-CTRL] | Idem. |
| MAPK cascade | [NO-CTRL] | Idem. |
| DNA computing designs | [NO-CTRL] | Idem. |
| DNA walkers | [NO-CTRL] | Idem. |
| Simple molecular reactions (Shapiro) | [NO-CTRL] | Idem. |
| Circadian clock (Barkai-Leiber) | [NO-CTRL] | Idem. |

## Planning and Synthesis

(imported: `task_graph`, `uav_planning`, `autonomous_driving`,
`vehicle_control_hostile`, `collective_decision`, `robot_coordination`,
`self_adaptive`, `aircraft_power`)

| Case study | Code | Reason |
|---|---|---|
| Robotic motion planning and control | [REDUND] | Same reach+avoid core as `vehicle_control_hostile`. |
| Grid world robot | [REDUND]/[UNSURE] | Either duplicates `vehicle_control_hostile`, or (true pursuit game) its reachability can be FALSE -- result not certain. |
| Safe robot navigation among humans | [REDUND] | Same reach+avoid core as `autonomous_driving` (dropped as a duplicate). |
| Team formation protocol | [REDUND] | Same bounded-adversary reachability as `collective_decision` (dropped as a duplicate). |

## Game Theory

(imported: `microgrid`, `future_mi`)

| Case study | Code | Reason |
|---|---|---|
| Alternating offers / Rubinstein bargaining | [EQUI] | Non-zero-sum equilibrium; as a pure adversary the opponent refuses forever -> trivial FALSE. |
| Stable matchings | [EQUI]/[UNSURE] | A matching algorithm (Gale-Shapley); no genuine adversarial coalition objective. |

## Performance and Reliability

(imported: `embedded_control`, `workstation_cluster`)

| Case study | Code | Reason |
|---|---|---|
| NAND multiplexing | [NO-CTRL] | Reliability via redundancy, no controller. |
| The thinkteam user interface | [NO-CTRL] | Performance model, no strategic game. |
| Wireless communication cell | [NO-CTRL] | Performance model, no strategic game. |
| Simple peer-to-peer protocol | [NO-CTRL] | Epidemic file spread, no controller. |

## CTMC Benchmarks

| Case study | Code | Reason |
|---|---|---|
| Kanban system (Ciardo-Tilgner) | [NO-CTRL] | Pure performance CTMC. |
| Flexible manufacturing system (Ciardo-Trivedi) | [NO-CTRL] | Idem. |
| Cyclic server polling (Ibe-Trivedi) | [NO-CTRL] | Idem. |
| Tandem queueing network (Hermanns-Meyer-Kayser-Siegle) | [NO-CTRL] | Idem. |

## Miscellaneous

| Case study | Code | Reason |
|---|---|---|
| Random graphs | [NO-CTRL] | Not a reactive system. |
| The Ising model | [NO-CTRL] | Statistical physics, no agent. |
| Cognitive assistive technology: hand-washing | [POMDP] | Partially observable (noisy sensing of the user); perfect-info ATL would be unfaithfully optimistic. |
