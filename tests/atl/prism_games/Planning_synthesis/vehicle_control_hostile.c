// =====================================================================
// Probabilistically Safe Vehicle Control in a Hostile Environment
//   -- PRISM (MDP, de-probabilised)
// ---------------------------------------------------------------------
// Source : I. Cizelj, X. C. Ding, M. Lahijanian, A. Pinto, C. Belta,
//   "Probabilistically Safe Vehicle Control in a Hostile Environment",
//   IFAC World Congress 2011 (arXiv:1103.4065). PRISM case study.
// Original model description: see vehicle_control_hostile.txt
// ---------------------------------------------------------------------
// A vehicle moves through a partitioned city on a two-stage mission: reach the
// PICK-UP region, then the DROP-OFF region, while staying ALIVE. The
// environment is threat-rich -- moving adversaries (Poisson processes) and
// static obstacles give every region crossing a non-zero probability of LOSING
// the vehicle (mission failure). The paper synthesises the reactive strategy
// that MAXIMISES the mission probability, but that probability is < 1 (0.141
// and 0.805 for the two scenarios of the paper): even the safest route keeps a
// residual chance of being lost. We de-probabilise this residual loss as a
// demonic choice -- the environment may inflict the loss the vehicle cannot
// rule out.
//
//   agent "veh" = input("veh")  -> vehicle controller (coalition, angelic)
//   agent "env" = input("env")  -> adversaries + obstacles (adversary, demonic)
//
// Mission -- reach pick-up then drop-off while staying alive -- expected
// UNKNOWN (a soundness witness: the paper's maximal probability is < 1, so the
// vehicle cannot SURELY complete the mission against a worst-case loss):
//   -atl "<veh>F{delivered == 1}"
// =====================================================================

int main() {
    int phase = 0;         // 0: heading to pick-up; 1: picked up, heading to drop-off
    int delivered = 0;     // mission accomplished (drop-off reached while alive)?
    int alive = 1;         // vehicle not yet lost
    while (delivered == 0 && alive == 1) {
        int cross = input("veh");   // vehicle reactively crosses toward its current target
        int lost  = input("env");   // residual loss the best route cannot eliminate
        if (cross == 1) {
            if (lost == 1) {
                alive = 0;          // lost while crossing a threatened region -> mission fails
            } else {
                phase = phase + 1;  // safely reached the next target region
                if (phase >= 2) { delivered = 1; }   // pick-up (phase 1) then drop-off (phase 2)
            }
        }
    }
}
