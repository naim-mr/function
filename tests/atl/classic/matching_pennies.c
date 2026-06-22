// =====================================================================
// Matching Pennies -- minimal concurrent game (ATL vs CTL)
// ---------------------------------------------------------------------
// Source : R. Alur, T. A. Henzinger, O. Kupferman,
//          "Alternating-Time Temporal Logic", JACM 49(5), 2002.
//          https://www.cis.upenn.edu/~alur/Jacm02.pdf
// Original concurrent game structure: see originals/matching_pennies.cgs.txt
// ---------------------------------------------------------------------
// Two players simultaneously pick a bit. The "matcher" wins iff the bits
// are equal. Neither player alone has a winning strategy (simultaneous
// move, no information) -- this is the textbook case where ATL differs
// from CTL.
//
//   agents "m" (matcher) and "h" (hider)
//
// Matcher alone has NO winning strategy (expected UNKNOWN):
//   -atl "<m>F{win == 1}"
// The grand coalition trivially wins (TRUE):
//   -atl "<m,h>F{win == 1}"
// =====================================================================

int main() {
    int win = 0;
    int a = input("m");   // matcher's bit
    int b = input("h");   // hider's bit
    if (a > 0) { a = 1; } else { a = 0; }
    if (b > 0) { b = 1; } else { b = 0; }
    if (a == b) { win = 1; }
    while (true) {}        // observe the outcome
}
