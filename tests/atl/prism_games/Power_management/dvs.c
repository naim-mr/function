// =====================================================================
// Real-Time Dynamic Voltage Scaling -- PRISM case study (de-prob., game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Real-time dynamic voltage scaling"
//          (Pillai & Shin).  https://www.prismmodelchecker.org/casestudies/voltage.php
// Original model description: see dvs.txt
// ---------------------------------------------------------------------
// Dynamic voltage scaling is a technique used to address the trade-off between the battery life and the performance 
// of battery powered processors. 
// Tasks of varying size // arrive (environment). The scheduler must keep the backlog under the
// deadline buffer -- i.e. never miss a deadline -- whatever the workload.
//
//   agent "dvs" = input("dvs")  -> voltage/frequency scheduler (coalition, angelic)
//   agent "env" = input("env")  -> task workload (adversary)
//
// The scheduler never misses a deadline (TRUE):
//   -atl "<dvs>G{missed == 0}"
// =====================================================================

int main() {
    int buf = input("env");    // deadline buffer (max tolerated backlog): arbitrary, not fixed
    if (buf < 0) buf = 0;
    int backlog = 0;       // accumulated unfinished work units
    int missed = 0;        // a deadline was missed this slot?
    while (1) {
        int load = input("env");   // env: 1 = heavy task (2 units), 0 = light (1 unit)
        int hi   = input("dvs");   // scheduler: 1 = high freq (clears 2), 0 = low (clears 1)
        if (load == 1) { backlog = backlog + 2; } else { backlog = backlog + 1; }
        if (hi == 1) { backlog = backlog - 2; } else { backlog = backlog - 1; }
        if (backlog < 0) { backlog = 0; }
        missed = 0;
        if (backlog > buf) { missed = 1; }   // deadline buffer exceeded
    }
}
