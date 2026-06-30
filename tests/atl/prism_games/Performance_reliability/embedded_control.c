// =====================================================================
// Embedded Control System -- PRISM case study (de-probabilised, game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Embedded control system"
//          (Muppala, Ciardo & Trivedi).
//   https://www.prismmodelchecker.org/casestudies/
// Original model description: see embedded_control.txt
// ---------------------------------------------------------------------
// An embedded controller drives N redundant components (sensors / actuators).
// Components fail over time; a repair/reconfiguration unit restores them. The
// system stays operational as long as at least one component is up. The
// controller keeps the system operational whatever the failures. The redundancy
// N is arbitrary -- NOT fixed in advance -- so the property holds for any size.
//
//   agent "ctrl" = input("ctrl")  -> repair/reconfiguration unit (coalition)
//   agent "env"  = input("env")   -> component failures + redundancy size (adversary)
//
// The controller keeps the system operational forever (TRUE):
//   -atl "<ctrl>G{operational == 1}"
// The controller survives the whole mission, i.e. stays up until the deadline
// (TRUE) -- discrete analog of the time-bounded "no failure within T":
//   -atl "<ctrl>U{operational == 1}{t >= deadline}"
// The failures cannot force the system down (UNKNOWN) -- adversarial dual,
// qualitative core of P=?[ F down ]:
//   -atl "<env>F{operational == 0}"
// =====================================================================

int main() {
    int n = input("env");      // number of redundant components: arbitrary, not fixed
    if (n < 1) n = 1;          // the system has at least one component
    int up = n;                // all components start healthy
    int operational = 1;       // system operational?
    int deadline = input("env"); // mission length (step deadline): arbitrary, not fixed
    int t = 0;                 // step clock (discrete analog of elapsed time)
    while (1) {
        int fail   = input("env");    // a component fails this round?
        int repair = input("ctrl");   // controller repairs a component?
        if (fail == 1) { if (up > 0) { up = up - 1; } }
        if (repair == 1) { if (up < n) { up = up + 1; } }
        operational = 1;
        if (up == 0) { operational = 0; }   // all redundancy lost -> down
        t = t + 1;                          // a step elapses
    }
}
