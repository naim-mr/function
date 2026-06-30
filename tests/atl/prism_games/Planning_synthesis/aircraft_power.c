// =====================================================================
// Aircraft Power Distribution -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Aircraft electrical power distribution".
//   https://www.prismmodelchecker.org/games/ (compositional strategy synth.)
// Original model description: see aircraft_power.txt
// ---------------------------------------------------------------------
// An electrical bus carries a critical LOAD with a power DEMAND. Power is
// supplied by generators, each with a power CAPACITY, routed to the bus
// through controllable contactors. One generator may be unavailable each round
// (environment); the control unit connects the bus to a generator. The bus is
// adequately powered when the supplied power meets the demand:  supplied >= demand.
// All quantities (capacity, demand, generator count) are arbitrary -- NOT fixed
// in advance; the demand never exceeds a single generator's capacity, so a
// healthy generator can always cover it.
//
//   agent "ctrl" = input("ctrl")  -> bus control unit (coalition, angelic)
//   agent "env"  = input("env")   -> generator outages + capacities (adversary)
//
// The control unit keeps the bus adequately powered forever (TRUE):
//   -atl "<ctrl>G{supplied >= demand}"
// =====================================================================

int main() {
    int cap = input("env");      // power capacity of a generator: arbitrary, not fixed
    if (cap < 1) cap = 1;
    int demand = input("env");   // critical-bus power demand: arbitrary, not fixed
    if (demand < 0) demand = 0;
    if (demand > cap) demand = cap;  // a single healthy generator can cover the demand
    int gens = input("env");     // number of generators: arbitrary, not fixed
    if (gens < 2) gens = 2;      // at least one spare to route around an outage
    int supplied = cap;          // power currently delivered to the critical bus
    while (1) {
        int down = input("env");   // which generator is unavailable this round (1..gens)
        if (down < 1) down = 1;
        if (down > gens) down = gens;
        int sw = input("ctrl");    // control unit connects the bus to generator sw (1..gens)
        if (sw < 1) sw = 1;
        if (sw > gens) sw = gens;
        // power delivered = the connected generator's capacity, or 0 if it is down
        if (sw == down) { supplied = 0; }
        else { supplied = cap; }
    }
}
