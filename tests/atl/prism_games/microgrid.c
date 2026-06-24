// =====================================================================
// Microgrid Demand-Side Management -- PRISM-games case study (de-prob.)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Microgrid demand-side management".
//   https://www.prismmodelchecker.org/games/casestudies/mdsm.php
// Original model description: see microgrid.txt
// ---------------------------------------------------------------------
// Several households schedule electrical loads on a shared microgrid. A
// controller may defer a household's load to keep the instantaneous total
// load on the grid under a safety cap, whatever the households demand.
//
//   agent "ctrl" = input("ctrl")  -> grid controller (coalition, angelic)
//   agent "hh"   = input("hh")    -> household demands (adversary)
//
// Controller keeps total load under the cap (TRUE):
//   -atl "<ctrl>G{load <= 3}"
// =====================================================================

int main() {
    int load = 0;          // instantaneous load on the grid
    while (1) {
        int d1 = input("hh");     // household 1 wants to run a load?
        int d2 = input("hh");     // household 2 wants to run a load?
        int admit = input("ctrl");// controller: 0 none, 1 hh1, 2 hh2, 3 both
        load = 0;
        if (admit == 1) { if (d1 != 0) { load = 1; } }
        if (admit == 2) { if (d2 != 0) { load = 1; } }
        if (admit == 3) {
            if (d1 != 0) { load = load + 1; }
            if (d2 != 0) { load = load + 1; }
        }
    }
}
