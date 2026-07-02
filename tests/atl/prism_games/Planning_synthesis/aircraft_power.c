// =====================================================================
// Aircraft Power Distribution -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Aircraft electrical power distribution".
//   https://www.prismmodelchecker.org/games/ (compositional strategy synth.)
// Original model description: see aircraft_power.txt
// ---------------------------------------------------------------------
// The critical bus must keep delivering power to its LOAD (demand). Rather than
// a generator on/off flag, we track the ENERGY BALANCE on the bus as a quantity.
// Each round the environment causes a power LOSS on the bus (a generator outage
// or a leak removes up to `cap` units); the control unit re-routes power from
// the remaining generators, restoring up to `cap` units. The bus is adequately
// powered while the delivered power stays at or above the demand.
//
//   agent "ctrl" = input("ctrl")  -> bus control unit (coalition, angelic)
//   agent "env"  = input("env")   -> power losses / outages (adversary)
//
// The control unit keeps the bus adequately powered forever (TRUE):
//   -atl "<ctrl>G{supplied >= demand}"
// The losses cannot force a brown-out (UNKNOWN) -- adversarial dual:
//   -atl "<env>F{supplied < demand}"
// =====================================================================

int main() {
    int cap = input("env");      // power a generator can supply / lose per round: arbitrary
    if (cap < 1) cap = 1;
    int demand = input("env");   // critical-bus power demand: arbitrary, not fixed
    if (demand < 0) demand = 0;
    if (demand > cap) demand = cap;  // a single healthy generator can cover the demand
    int supplied = cap;          // power currently delivered to the critical bus
    while (1) {
        int loss = input("env");   // power lost this round (outage / leak): 0..cap
        if (loss < 0) loss = 0;
        if (loss > cap) loss = cap;
        int add = input("ctrl");   // power the control unit re-routes back: 0..cap
        if (add < 0) add = 0;
        if (add > cap) add = cap;
        supplied = supplied - loss + add;   // net power balance on the bus
        if (supplied > cap) supplied = cap; // the bus cannot hold more than a generator's capacity
        if (supplied < 0) supplied = 0;
    }
}
