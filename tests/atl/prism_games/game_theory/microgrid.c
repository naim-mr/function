// =====================================================================
// Microgrid Demand-Side Management -- PRISM-games case study (de-prob.)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Microgrid demand-side management".
//   https://www.prismmodelchecker.org/games/casestudies/mdsm.php
// Original model description: see microgrid.txt
// ---------------------------------------------------------------------
// N households connected to a shared microgrid each demand to run a load
// every round; a controller admits a subset. The instantaneous load is the
// number of admitted households that demand. The controller keeps the load
// within the grid capacity, whatever the households demand. Both the number
// of households (n) and the capacity (cap) are arbitrary -- NOT fixed in
// advance -- so the property must hold for any grid size and any capacity.
//
//   agent "ctrl" = input("ctrl")  -> grid controller (coalition, angelic)
//   agent "hh"   = input("hh")    -> household demands + instance sizes (adversary)
//
// Controller keeps total load under the cap (TRUE):
//   -atl "<ctrl>G{load <= cap}"
// =====================================================================

int main() {
    int cap = input("constructor");     // grid capacity: arbitrary, not fixed in advance
    if (cap < 0) cap = 0;      // a capacity is non-negative
    int n = input("hh");       // number of households: arbitrary, not fixed in advance
    int load = 0;              // instantaneous load on the grid
    while (1) {
        load = 0;
        int i = 0;
        while (i < n) {
            int demand = input("hh");    // household i wants to run a load?
            int admit  = input("ctrl");  // controller admits household i?
            if (demand != 0) {
                if (admit != 0) { load = load + 1; }   // admitted demand adds to the load
            }
            i = i + 1;
        }
    }
}
