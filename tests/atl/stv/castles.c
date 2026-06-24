// =====================================================================
// Castles -- standard ATL_ir scalability benchmark
// ---------------------------------------------------------------------
// Source : STV (StraTegic Verifier), Jamroga / Kurpiewski et al.
//          Repo  : https://github.com/blackbat13/stv  (built-in "Castles" model)
//          Paper : "Fixpoint Approximation of Strategic Abilities under
//                   Imperfect Information", https://arxiv.org/pdf/1612.02684
// Original model description: see originals/castles.txt
// ---------------------------------------------------------------------
// A coalition of workers of castle 1 attacks castle 2. Each round our
// workers may attack (lowering the enemy HP) while the enemy attacks back.
// The coalition has a strategy to defeat castle 2 (reduce its HP to 0).
//
//   agent "att" = input("att")  -> our workers (coalition, angelic)
//   agent "def" = input("def")  -> enemy workers (adversary)
//
// Coalition can defeat castle 2 (TRUE):
//   -atl "<att>F{hp2 == 0}"
// =====================================================================

int main() {
    int hp1 = 5;   // our castle (enough workers to outlast the enemy)
    int hp2 = 3;   // enemy castle
    while (hp2 > 0) {
        int act = input("att");    // our workers: 1 = attack
        int enemy = input("def");  // enemy workers: 1 = attack
        if (hp1 > 0) {
            if (act == 1) { hp2 = hp2 - 1; }
        }
        if (hp2 > 0) {
            if (enemy == 1) {
                if (hp1 > 0) { hp1 = hp1 - 1; }
            }
        }
    }
    while (1) {}                // observe the defeat of castle 2
}
