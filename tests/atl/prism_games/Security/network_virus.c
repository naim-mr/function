// =====================================================================
// Network Virus Infection -- PRISM case study (de-probabilised, game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Network Virus Infection".
//   https://www.prismmodelchecker.org/casestudies/
// Original model description: see network_virus.txt
// ---------------------------------------------------------------------
// A virus spreads across a network; an administrator runs disinfection /
// patching. Each round the virus tries to infect one more node; the admin
// may disinfect one node. The admin keeps the number of infected nodes
// bounded whatever the virus does.
//
//   agent "admin" = input("admin")  -> administrator (coalition, angelic)
//   agent "virus" = input("virus")  -> virus spread (adversary)
//
// The administrator keeps infections bounded (TRUE):
//   -atl "<admin>G{infected <= cap}"
// =====================================================================

int main() {
    int cap = input("virus");  // tolerated infection bound: arbitrary, not fixed in advance
    if (cap < 1) cap = 1;      // the count transiently reaches 1 before disinfection
    int infected = 0;      // number of infected nodes
    while (1) {
        int spread = input("virus");   // virus infects a node this round?
        int clean  = input("admin");   // admin disinfects a node this round?
        if (spread == 1) { infected = infected + 1; }
        if (clean == 1) { if (infected > 0) { infected = infected - 1; } }
    }
}
