// =====================================================================
// DoS Threat Quantification (HIP base-exchange) -- PRISM (de-probabilised)
// ---------------------------------------------------------------------
// Source : S. Basagiannis, P. Katsaros, A. Pombortsis, N. Alexiou,
//   "A Probabilistic Attacker Model for Quantitative Verification of DoS
//    Security Threats", COMPSAC 2008 (Computers & Security 2009).
// Original model description: see dos_quantification.txt
// ---------------------------------------------------------------------
// A DoS threat against the Host Identity Protocol (HIP) base-exchange, which
// uses client puzzles for DoS protection. The puzzle in message R1 is NOT in
// the signed part, so the attacker COUNTERFEITS R1 messages and replays them,
// tricking the Initiator into solving bogus puzzles. Each counterfeited
// message occupies a slot in the Initiator's admission queue (capacity B); the
// Initiator can only verify/clear a bounded number per round (puzzle solving is
// costly). Denial of service is reached when the admission queue is full -- any
// valid R1 is then dropped and the Initiator is unavailable.
//
// The paper's finding is that the attack SUCCEEDS (P ~ 0.895). So we model it
// as the ATTACKER's reachability of a full admission queue, not a defender
// safety invariant.
//
//   agent "atk" = input("atk")  -> attacker / zombies (coalition, angelic)
//   agent "ini" = input("ini")  -> Initiator's verification rate (adversary, bounded)
//
// The attacker exhausts the Initiator's admission queue (TRUE):
//   -atl "<atk>F{queue >= B}"
// =====================================================================

int main() {
    int B = input("ini");      // Initiator admission queue capacity: arbitrary
    if (B < 1) B = 1;
    int clear = input("ini");  // messages the Initiator verifies/clears per round
    if (clear < 0) clear = 0;  // bounded: solving/verifying puzzles is costly
    int queue = 0;             // counterfeited messages occupying the admission queue
    while (queue < B) {
        int counterfeit = input("atk");  // counterfeited R1 messages replayed this round
        if (counterfeit < 0) counterfeit = 0;
        queue = queue + counterfeit - clear;
        if (queue < 0) queue = 0;
    }
}
