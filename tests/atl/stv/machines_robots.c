// =====================================================================
// Machines & Robots -- STV benchmark (factory scenario)
// ---------------------------------------------------------------------
// Source : STV (StraTegic Verifier), Jamroga / Kurpiewski et al.
//          https://github.com/blackbat13/stv  (built-in "Machines & Robots")
// Original model description: see machines_robots.txt
// ---------------------------------------------------------------------
// Robots operate machines on a factory line to produce items. Machines may
// break down (environment); a robot can either produce one item or repair.
// The coalition of robots can reach a production target despite breakdowns.
//
//   agents "r1","r2" = input("r1"), input("r2")  -> robots (coalition)
//   agent  "env"     = input("env")              -> breakdowns (adversary)
//
// The robots can reach the production target (TRUE):
//   -atl "<r1,r2>F{produced >= 4}"
// =====================================================================

int main() {
    int produced = 0;
    int broken = 0;        // is the line broken?
    while (produced < 4) {
        int fault = input("env");   // environment may break the line
        if (fault == 1) { broken = 1; }
        int a1 = input("r1");       // robot 1: 1 produce, 2 repair
        int a2 = input("r2");       // robot 2: 1 produce, 2 repair
        if (a1 == 2) { broken = 0; }
        if (a2 == 2) { broken = 0; }
        if (broken == 0) {
            if (a1 == 1) { produced = produced + 1; }
            if (a2 == 1) { produced = produced + 1; }
        }
    }
    while (true) {}
}
