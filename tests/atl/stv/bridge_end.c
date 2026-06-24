// =====================================================================
// Bridge End-play -- STV benchmark (card game, imperfect information)
// ---------------------------------------------------------------------
// Source : STV (StraTegic Verifier), Jamroga / Kurpiewski et al.
//          https://github.com/blackbat13/stv   (built-in "Bridge" model)
// Original model description: see bridge_end.txt
// ---------------------------------------------------------------------
// A simplified trick-taking end-play: over 3 tricks the declarer plays a
// card and the defender plays a card; the higher card wins the trick.
// The declarer ("decl") can guarantee winning the majority of tricks.
//
//   agent "decl" = input("decl")  -> declarer (coalition, angelic)
//   agent "def"  = input("def")   -> defender (adversary)
//
// NOTE: NUMERIC SIMPLIFICATION of the STV double-dummy model (the real
// game has hidden hands / imperfect information). Cards are tracked with
// availability flags; reusing a spent card forfeits the trick.
//
// Declarer can win the majority of tricks (TRUE):
//   -atl "<decl>F{tricks >= 2}"
// =====================================================================

int main() {
    // declarer holds cards {2,4,9}; defender holds {3,5,8}
    int d_lo = 2; int d_mid = 4; int d_hi = 9;
    int x_lo = 3; int x_mid = 5; int x_hi = 8;
    int hd_lo = 1; int hd_mid = 1; int hd_hi = 1;
    int hx_lo = 1; int hx_mid = 1; int hx_hi = 1;
    int tricks = 0;
    int round = 0;
    while (round < 3) {
        // defender (adversary) plays a card
        int xc = input("def");
        int def = 0;
        if (xc <= 0) { if (hx_lo == 1) { def = x_lo; hx_lo = 0; } }
        else if (xc == 1) { if (hx_mid == 1) { def = x_mid; hx_mid = 0; } }
        else { if (hx_hi == 1) { def = x_hi; hx_hi = 0; } }
        // declarer (angelic) plays a card
        int dc = input("decl");
        int dec = 0;
        if (dc <= 0) { if (hd_lo == 1) { dec = d_lo; hd_lo = 0; } }
        else if (dc == 1) { if (hd_mid == 1) { dec = d_mid; hd_mid = 0; } }
        else { if (hd_hi == 1) { dec = d_hi; hd_hi = 0; } }
        if (dec > def) { tricks = tricks + 1; }
        round = round + 1;
    }
    while (1) {}
}
