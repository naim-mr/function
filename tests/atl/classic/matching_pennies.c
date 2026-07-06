// =====================================================================
// Matching Pennies -- minimal concurrent game (ATL vs CTL)
// ---------------------------------------------------------------------
// "Matching pennies" is a classic strictly-competitive zero-sum game:
//   M. J. Osborne, A. Rubinstein, "A Course in Game Theory",
//   MIT Press, 1994, Example 17.1:
//   "Each of two people chooses Head or Tail. If the choices DIFFER,
//    person 1 pays person 2 a dollar; if they are the SAME, person 2 pays
//    person 1 a dollar."  -> person 1 wins on a match, person 2 on a mismatch.
// We expose BOTH payoffs (gain1, gain2 = +/-1), as in the payoff matrix.
// ATL differs from CTL (no single agent can force its preferred outcome).
// Game structure: see matching_pennies.cgs.txt
// ---------------------------------------------------------------------
//   agent "p1" = input("p1")  -> person 1 (wins iff choices are the same)
//   agent "p2" = input("p2")  -> person 2 (wins iff choices differ)
//
// Person 1 cannot force a positive gain (expected UNKNOWN):
//   -atl "<p1>F{gain1 == 1}"
//
// CAVEAT (simultaneity): this is a genuinely SIMULTANEOUS one-shot game,
// but the analysis is turn-based. With p1 written first we get the sound
// reading exists-p1 forall-p2, so <p1>F{gain1==1} is faithful. The symmetric
// query <p2>F{gain2==1} is NOT sound here (p2, written second, would be
// clairvoyant); a sound test for person 2 needs the swapped-order model.
// =====================================================================

int main() {
    int a = input("p1",0,1);   // person 1's choice: Head (1) / Tail (0)
    int b = input("p2",0,1);   // person 2's choice: Head (1) / Tail (0)
    int gain1=0;
    int gain2=0;
    if (a == b) {          // same   -> person 2 pays person 1
        gain1 = 1;
        gain2 = -1;
    } else {               // differ -> person 1 pays person 2
        gain1 = -1;
        gain2 = 1;
    }
    while (1) {}           // observe the payoffs
}
