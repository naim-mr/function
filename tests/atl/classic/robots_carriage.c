// =====================================================================
// Two Robots and a Carriage -- canonical CGS example for ATL
// ---------------------------------------------------------------------
// Source : S. Demri, V. Goranko, M. Lange,
//          "Temporal Logics in Computer Science", Cambridge Univ. Press,
//          2016, Chapter 9 "Alternating-Time Temporal Logics".
// Faithful CGS: see robots_carriage.cgs.txt
// ---------------------------------------------------------------------
// A carriage sits on a CIRCULAR track with 3 positions {0,1,2}. At each
// step each robot independently chooses to PUSH or WAIT. The carriage moves
// ONLY IF EXACTLY ONE robot pushes:
//   - only r1 pushes -> clockwise        (+1 mod 3)
//   - only r2 pushes -> counter-clockwise (-1 mod 3)
//   - both push, or both wait -> stationary (the pushes cancel).
//
//   agents "r1" (clockwise) and "r2" (counter-clockwise)
//
// The coalition of both robots can move the carriage to a target:
//   -atl "<r1,r2>F{pos == 1}"     (TRUE)
// A single robot cannot force it -- the other has a counter-strategy that
// keeps the carriage still (see robots_carriage.single.json: UNKNOWN).
// =====================================================================

int main() {
    int pos = 0;
    while (1) {
        int p1 = input("r1",0,1);   // robot 1: push (1) or wait (0)
        int p2 = input("r2",0,1);   // robot 2: push (1) or wait (0)
        // the carriage moves only if EXACTLY one robot pushes
        if (p1 == 1) {
            if (p2 == 0) {                    // only r1 -> clockwise (+1 mod 3)
                if (pos == 2) { pos = 0; } else { pos = pos + 1; }
            }
        } else {
            if (p2 == 1) {                    // only r2 -> counter-clockwise (-1 mod 3)
                if (pos == 0) { pos = 2; } else { pos = pos - 1; }
            }
        }
    }
}
