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
// The controller completes the MISSION within the global deadline (TRUE). Two
// clocks: a global clock t (always ticking) and the mission uptime work (only
// advances while the system is up), so an outage burns global time without
// progressing the mission. The controller accumulates the required uptime
// (work >= mission) before the global clock runs out (t <= deadline):
//   -atl "<ctrl>F{AND{work >= mission}{t <= deadline}}"
// The failures cannot force the system down (UNKNOWN) -- adversarial dual,
// qualitative core of P=?[ F down ]:
//   -atl "<env>F{operational == 0}"
// =====================================================================

int main() {
    int n = input("env");      // number of redundant components: arbitrary, not fixed
    assert(n>=0);         // the system has at least one component
    int up = n;                // all components start healthy
    int operational = 1;       // system operational?
    int deadline = input("env"); // global time budget for the mission: arbitrary, not fixed
    assert(n>=0);
    int mission = input("env");  // required operational uptime (mission workload): arbitrary
    assert(n>=0);
    if (mission > deadline) mission = deadline;  // the mission fits within the horizon
    int t = 0;                 // global clock: elapsed real time
    int work = 0;              // mission progress: operational uptime accumulated
    while (1) {
        int fail   = input("env",0,1);    // a component fails this round?
        int repair = input("ctrl",0,1);   // controller repairs a component?
        if (fail == 1) { if (up > 0) { up = up - 1; } }
        if (repair == 1) { if (up < n) { up = up + 1; } }
        operational = 1;
        if (up == 0) { operational = 0; }        // all redundancy lost -> down
        t = t + 1;                               // global time always advances
        if (operational == 1) { work = work + 1; } // mission advances only while up
    }
}
