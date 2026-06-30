// =====================================================================
// Self-Adaptive / Collective Adaptive Systems resilience -- PRISM-games
// ---------------------------------------------------------------------
// Source : T. Glazier, J. Camara, B. Schmerl, D. Garlan,
//   "Analyzing Resilience Properties of Different Topologies of Collective
//    Adaptive Systems", SEAMS/SMG study (CMU).
// Original model description: see self_adaptive.txt
// ---------------------------------------------------------------------
// A collective of N self-adaptive managers (CAS) defends against an external
// attacker. Modelled as a turn-based game: the cooperative self-adaptive
// managers are ONE coalition player, the attacker is the adversary. The
// attacker breaches members using bounded resources; a member that detects an
// attack NOTIFIES others (per the communication topology), and a notified
// member ADAPTS, becoming invulnerable. The metric is how many members survive.
//
//   agent "cas" = input("cas")  -> the cooperative self-adaptive managers (coalition)
//   agent "att" = input("att")  -> the attacker (adversary): breaches + sizes
//
// Resilience -- the collective preemptively protects members (TRUE):
//   -atl "<cas>F{adapted >= 1}"
//   (the collective can adapt at least one member before it is compromised;
//    the quantitative survival fraction -- topology-dependent in the paper -- is
//    abstracted. Dually, <att>F{compromised >= N} -- "the attacker compromises
//    the WHOLE collective" -- is expected UNKNOWN: notification saves some.)
// =====================================================================

int main() {
    int N = input("att");          // collective size: arbitrary, not fixed in advance
    if (N < 1) N = 1;
    int resources = input("att");  // attacker's bounded breach budget
    if (resources < 0) resources = 0;
    int compromised = 0;           // members breached by the attacker
    int adapted = 0;               // members that adapted (invulnerable)
    while (compromised + adapted < N) {
        int notify = input("cas");   // the collective notifies -> a member adapts?
        int breach = input("att");   // the attacker breaches an un-adapted member?
        if (notify == 1) { adapted = adapted + 1; }
        if (breach == 1 && resources > 0) {
            compromised = compromised + 1;
            resources = resources - 1;
        }
    }
}
