// =====================================================================
// Robot Coordination -- PRISM-games case study (de-probabilised rPATL)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Robot coordination".
//   https://www.prismmodelchecker.org/games/casestudies/robot_coordination.php
//   Tool/papers: https://www.prismmodelchecker.org/games/
// Original model description: see robot_coordination.txt
// ---------------------------------------------------------------------
// Two robots move along a 1-D corridor of length L toward a meeting point.
// The floor is "slippery": the environment may push a robot back by one
// cell. The coalition of robots can still guarantee that both reach the
// goal cell (their positions meet at L).
//
//   agents "r1","r2" = input("r1"), input("r2")  -> robots (coalition)
//   agent  "env"     = input("env")              -> slip / disturbance (adversary)
//
// Robots can coordinate to reach the goal (TRUE):
//   -atl "<r1,r2>F{x1 >= 4}"
// =====================================================================

int main() {
    int x1 = 0;            // position of robot 1
    int x2 = 0;            // position of robot 2 (kept for symmetry)
    while (x1 < 4) {
        int slip = input("env");   // environment may slip robot 1 back
        int m1 = input("r1");      // robot 1 step
        int m2 = input("r2");      // robot 2 step
        if (m1 == 1) { x1 = x1 + 2; }   // a firm step advances 2
        if (slip == 1) { x1 = x1 - 1; } // slip costs 1  -> net +1 guaranteed
        if (m2 == 1) { x2 = x2 + 1; }
    }
    while (true) {}
}
