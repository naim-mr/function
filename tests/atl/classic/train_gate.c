// =====================================================================
// Train Gate Controller -- classic ATL example
// ---------------------------------------------------------------------
// Source : R. Alur, T. A. Henzinger, O. Kupferman,
//          "Alternating-Time Temporal Logic", JACM 49(5), 2002.
//          https://www.cis.upenn.edu/~alur/Jacm02.pdf  (Sect. 2, running example)
// Original concurrent game structure: see originals/train_gate.cgs.txt
// ---------------------------------------------------------------------
// Two trains may request access to a shared tunnel; a controller decides
// whom to admit. The controller has a strategy to keep mutual exclusion
// of the tunnel forever, whatever the trains request.
//
//   agent "controller" = input("controller")  -> coalition (angelic)
//   agents "train1"/"train2"                   -> environment (adversary)
//
// Property (controller enforces safety):
//   -atl "<controller>G{in1 + in2 <= 1}"
// =====================================================================

int main() {
    int in1 = 0;   // train 1 occupies the tunnel?
    int in2 = 0;   // train 2 occupies the tunnel?
    while (true) {
        int r1 = input("train1");        // train 1 requests access (adversary)
        int r2 = input("train2");        // train 2 requests access (adversary)
        int admit = input("controller"); // controller: 0 none, 1 train1, 2 train2
        in1 = 0;
        in2 = 0;
        // the controller never admits a train into an occupied tunnel
        if (admit == 1) {
            if (r1 != 0) { in1 = 1; }
        }
        if (admit == 2) {
            if (r2 != 0) { in2 = 1; }
        }
    }
}
