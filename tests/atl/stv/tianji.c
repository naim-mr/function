// =====================================================================
// Tian Ji's Horse Racing -- standard ATL_ir scalability benchmark
// ---------------------------------------------------------------------
// Source : STV (StraTegic Verifier), Jamroga / Kurpiewski et al.
//          Repo  : https://github.com/blackbat13/stv  (built-in "TianJi" model)
//          Paper : "Fixpoint Approximation of Strategic Abilities under
//                   Imperfect Information", https://arxiv.org/pdf/1612.02684
// Original model description: see originals/tianji.txt
// ---------------------------------------------------------------------
// Each of Tian Ji's horses is slightly slower than the King's horse of the
// same grade, but faster than the King's lower grades:
//     Tian Ji : low=2, mid=4, top=6        King : low=3, mid=5, top=7
// Over three rounds Tian Ji (choosing which of his remaining horses to
// race) can guarantee winning the majority (>= 2 races).
//
//   agent "tj"   = input("tj")    -> Tian Ji (coalition, angelic)
//   agent "king" = input("king")  -> the King (adversary)
//
// Note: NUMERIC SIMPLIFICATION of the STV model (horses tracked with
// availability flags instead of a set; if a player reuses a spent horse
// it forfeits that round). See originals/tianji.txt for the faithful model.
//
// Tian Ji can guarantee the majority (TRUE):
//   -atl "<tj>F{wins >= 2}"
// =====================================================================

int main() {
    int t_low = 2; int t_mid = 4; int t_top = 6;   // Tian Ji's horses
    int k_low = 3; int k_mid = 5; int k_top = 7;   // King's horses
    // availability flags
    int ht_low = 1; int ht_mid = 1; int ht_top = 1;
    int hk_low = 1; int hk_mid = 1; int hk_top = 1;
    int wins = 0;
    int round = 0;
    while (round < 3) {
        // King (adversary) sends one of his horses: 0 low, 1 mid, 2 top
        int kc = input("king");
        int king = 0;                       // 0 = forfeit (reused horse)
        if (kc <= 0) { if (hk_low == 1) { king = k_low; hk_low = 0; } }
        else if (kc == 1) { if (hk_mid == 1) { king = k_mid; hk_mid = 0; } }
        else { if (hk_top == 1) { king = k_top; hk_top = 0; } }
        // Tian Ji (angelic) sends one of his remaining horses
        int tc = input("tj");
        int mine = 0;                       // 0 = forfeit (reused horse)
        if (tc <= 0) { if (ht_low == 1) { mine = t_low; ht_low = 0; } }
        else if (tc == 1) { if (ht_mid == 1) { mine = t_mid; ht_mid = 0; } }
        else { if (ht_top == 1) { mine = t_top; ht_top = 0; } }
        if (mine > king) { wins = wins + 1; }
        round = round + 1;
    }
    while (true) {}                         // observe the number of wins
}
