// =====================================================================
// Drones & Pollution -- STV benchmark
// ---------------------------------------------------------------------
// Source : STV (StraTegic Verifier), Jamroga / Kurpiewski et al.
//          https://github.com/blackbat13/stv   (built-in "Drones" model)
// Original model description: see drones.txt
// ---------------------------------------------------------------------
// A team of drones patrols an area whose pollution level keeps rising
// (environment). Each round a drone may "clean" one unit of pollution.
// The coalition of drones has a strategy to keep the pollution bounded
// forever, whatever the environment does.
//
//   agents "d1","d2" = input("d1"), input("d2")  -> drones (coalition)
//   agent  "env"     = input("env")              -> pollution source (adversary)
//
// Two drones can keep pollution under control (TRUE):
//   -atl "<d1,d2>G{p <= 5}"
// =====================================================================

int main() {
    int p = 0;             // current pollution level
    while (true) {
        int rise = input("env");   // environment adds at most 2 units/round
        if (rise < 0) { rise = 0; }
        if (rise > 2) { rise = 2; }
        p = p + rise;
        int c1 = input("d1");      // drone 1 cleans?
        int c2 = input("d2");      // drone 2 cleans?
        if (c1 == 1) { if (p > 0) { p = p - 1; } }
        if (c2 == 1) { if (p > 0) { p = p - 1; } }
    }
}
