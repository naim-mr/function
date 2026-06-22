// =====================================================================
// Simple Arbiter -- reactive synthesis benchmark (SYNTCOMP)
// ---------------------------------------------------------------------
// Source : SYNTCOMP, "Simple Arbiter".
//   https://github.com/SYNTCOMP/benchmarks/tree/master/tlsf/simple_arbiter/parametric
// Original TLSF specification: see simple_arbiter.tlsf
// ---------------------------------------------------------------------
// Two clients request a shared resource; the arbiter grants it. Reactive
// synthesis asks for an arbiter strategy enforcing the spec against any
// request sequence -- exactly  <arb> phi  in ATL. We check the safety
// invariant: mutual exclusion of the grant lines.
//
//   agent "arb" = input("arb")  -> the arbiter (coalition, angelic)
//   agent "env" = input("env")  -> the requesting clients (adversary)
//
//   -atl "<arb>G{g1 + g2 <= 1}"
// =====================================================================

int main() {
    int g1 = 0;
    int g2 = 0;
    while (true) {
        int r1 = input("env");    // request client 1 (adversary)
        int r2 = input("env");    // request client 2 (adversary)
        int grant = input("arb"); // arbiter: 0 none, 1 client1, 2 client2
        g1 = 0;
        g2 = 0;
        if (grant == 1) { g1 = 1; }
        if (grant == 2) { g2 = 1; }
    }
}
