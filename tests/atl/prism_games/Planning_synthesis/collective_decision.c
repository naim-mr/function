// =====================================================================
// CDMSN: Collective Decision Making for Sensor Networks -- PRISM-games
// ---------------------------------------------------------------------
// Source : Chen, Forejt, Kwiatkowska, Parker, Simaitis,
//   "Automatic Verification of Competitive Stochastic Systems", FMSD 2013
//   (the rPATL journal paper), section 5.3 (CDMSN).
// Original model description: see collective_decision.txt
// ---------------------------------------------------------------------
// N sensors each store a preferred target among K targets, each target having a
// quality Q_k. The goal of the distributed consensus algorithm is for ALL
// sensors to agree on the target of MAXIMUM quality (the best target). Sensors
// communicate pairwise: when two compare preferences, one adopts the other's.
// Only a subset C of sensors is under our control (coalition); the rest are
// faulty / adversarial and keep advertising a worse target.
//
// As in the paper, the model is TURN-BASED with a (here NON-DETERMINISTIC)
// scheduler: each round exactly ONE sensor is active. The scheduler is part of
// the uncontrolled environment, so it is resolved demonically. If a controlled
// (coalition) sensor is scheduled, the coalition makes it adopt the best target
// (best++); if a faulty sensor is scheduled, it pulls a neighbour to a worse
// target (best--). We track best = number of sensors preferring the best
// target; consensus = (best == N).
//
//   agent "net" = input("net")  -> the controlled (honest) sensors (coalition)
//   agent "env" = input("env")  -> scheduler + faulty sensors + sizes (adversary)
//
// Can the coalition force consensus on the best target?
//   -atl "<net>F{best >= N}"
//   Expected UNKNOWN (soundness witness): under worst-case scheduling the
//   adversary can keep activating faulty sensors (and never the coalition),
//   so SURE consensus is not guaranteed -- matching the paper's probabilistic
//   results (P_max / R_min, robustness P_max[F good]) which are < 1. The paper
//   assumes RANDOM (fair) scheduling; the qualitative sure reading uses a
//   demonic scheduler instead.
// =====================================================================

int main() {
    int N = input("env");      // number of sensors: arbitrary, not fixed in advance
    if (N < 1) N = 1;
    int best = input("env");   // sensors initially preferring the best target
    if (best < 0) best = 0;
    if (best > N) best = N;
    while (best < N) {
        int sched = input("env");   // NON-DETERMINISTIC scheduler: which sensor is active?
        if (sched == 1) {
            // a controlled (coalition) sensor is scheduled
            int act = input("net");   // the coalition makes it adopt the best target?
            if (act == 1 && best < N) { best = best + 1; }
        } else {
            // a faulty sensor is scheduled -> it pulls a neighbour to a worse target
            if (best > 0) { best = best - 1; }
        }
    }
}
