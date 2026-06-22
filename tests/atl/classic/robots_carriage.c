// =====================================================================
// Two Robots and a Carriage -- classic ATL coalition example
// ---------------------------------------------------------------------
// Source : N. Bulling, V. Goranko, W. Jamroga,
//          "Logics for Reasoning about Strategic Abilities" (tutorial/handbook).
//          https://home.ipipan.waw.pl/w.jamroga/papers/satol15.pdf
// Original concurrent game structure: see originals/robots_carriage.cgs.txt
// ---------------------------------------------------------------------
// A carriage sits on a track. Two robots can each push it. A single robot
// alone cannot force the carriage to a target position (the other may push
// the opposite way), but the COALITION of both robots can.
//
//   agents "r1" and "r2" = input("r1"), input("r2")   (each pushes -1 / +1)
//
// Coalition CAN force the target (TRUE):
//   -atl "<r1,r2>F{pos >= 2}"
// A single robot CANNOT force it (expected UNKNOWN):
//   -atl "<r1>F{pos >= 2}"
// =====================================================================

int main() {
    int pos = 0;
    while (pos < 2) {
        int a = input("r1");   // robot 1 push
        int b = input("r2");   // robot 2 push
        if (a > 0) { a = 1; } else { a = -1; }
        if (b > 0) { b = 1; } else { b = -1; }
        pos = pos + a + b;     // both push +1  =>  pos += 2
    }
    while (true) {}            // observe the reached position
}
