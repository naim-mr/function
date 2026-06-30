// =====================================================================
// Dynamic Power Management -- PRISM case study (de-probabilised, game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Dynamic power management controllers".
//   https://www.prismmodelchecker.org/casestudies/power.php
// Original model description: see dynamic_power_management.txt
// ---------------------------------------------------------------------
// A power manager (PM) controls a service provider serving a request queue.
// Requests arrive from the environment; the PM decides each round whether to
// power the provider on and serve a request, trading energy for responsiveness.
// The PM keeps the request queue from overflowing whatever the arrivals.
//
//   agent "pm"  = input("pm")   -> power manager (coalition, angelic)
//   agent "env" = input("env")  -> request arrivals (adversary)
//
// The power manager never overflows the queue (TRUE):
//   -atl "<pm>G{queue <= cap}"
// =====================================================================

int main() {
    int cap = input("env");    // queue capacity: arbitrary, not fixed in advance
    if (cap < 1) cap = 1;      // at least one slot (the queue transiently holds 1)
    int queue = 0;         // pending service requests
    int on = 0;            // service provider powered on?
    while (1) {
        int arr = input("env");   // a request arrives this round?
        int cmd = input("pm");    // power manager: 1 = power on & serve, 0 = sleep
        if (arr == 1) { queue = queue + 1; }
        if (cmd == 1) { on = 1; if (queue > 0) { queue = queue - 1; } }
        else { on = 0; }
    }
}
