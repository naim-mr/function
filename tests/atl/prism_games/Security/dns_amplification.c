// =====================================================================
// DNS Bandwidth Amplification Attack -- PRISM case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : Deshpande, Katsaros, Basagiannis, Smolka,
//   "Formal Analysis of the DNS Bandwidth Amplification Attack and its
//    Countermeasures Using Probabilistic Model Checking", HASE 2011.
// Original model description: see dns_amplification.txt
// ---------------------------------------------------------------------
// A network of zombies floods a victim DNS server with AMPLIFIED bogus
// responses: each bogus request consumes EAF (effective amplification factor,
// ~15) units of the victim's bandwidth queue (capacity BQUL). The queue is
// drained by the server at rate `serve`; a filtering countermeasure blocks up
// to `fcap` bogus requests per round. Denial of service is reached when the
// bandwidth queue is exhausted (bw > BQUL).
//
// The paper's finding is that the attack SUCCEEDS (attack probability -> 1 as
// the number of zombies grows): with amplification, an attacker with enough
// volume overwhelms any finite service + bounded filtering. So we model it as
// the ATTACKER's reachability of bandwidth exhaustion, not a defender safety.
//
//   agent "atk" = input("atk")  -> zombies / attacker (coalition, angelic)
//   agent "def" = input("def")  -> server capacity + filtering (adversary, bounded)
//
// The attacker exhausts the victim's bandwidth (TRUE):
//   -atl "<atk>F{bw > BQUL}"
// =====================================================================

int main() {
    int BQUL = input("def");   // victim bandwidth queue capacity (packets): arbitrary
    if (BQUL < 1) BQUL = 1;
    int EAF = input("def");    // effective amplification factor: arbitrary, >= 1
    if (EAF < 1) EAF = 1;
    int serve = input("def");  // server service rate (packets drained per round)
    if (serve < 0) serve = 0;
    int fcap = input("def");   // filtering capacity (bogus requests blocked per round)
    if (fcap < 0) fcap = 0;
    int bw = 0;                // occupied bandwidth queue
    while (bw <= BQUL) {
        int z = input("atk");      // bogus requests injected by the zombies this round
        if (z < 0) z = 0;
        int filtered = z;
        if (filtered > fcap) filtered = fcap;   // filtering blocks at most fcap of them
        int bogus = (z - filtered) * EAF;       // the rest arrive AMPLIFIED (x EAF)
        bw = bw + bogus - serve;                 // queue grows by amplified bogus, drained by serve
        if (bw < 0) bw = 0;
    }
}
