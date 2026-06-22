// =====================================================================
// Round-Robin Arbiter -- reactive synthesis benchmark (SYNTCOMP)
// ---------------------------------------------------------------------
// Source : SYNTCOMP benchmark library, "Round Robin Arbiter".
//   https://github.com/SYNTCOMP/benchmarks/tree/master/tlsf/round_robin_arbiter/parametric
// Original TLSF specification: see originals/round_robin_arbiter.tlsf
// ---------------------------------------------------------------------
// An arbiter serves request signals on a shared bus. Reactive synthesis
// asks for a controller strategy enforcing the spec against any sequence
// of environment requests; this is exactly  <arbiter> phi  in ATL.
// Here we check the safety part: the arbiter keeps mutual exclusion of
// the grant lines (at most one grant high at a time).
//
//   agent "arb" = input("arb")  -> the arbiter (coalition, angelic)
//   agent "env" = input("env")  -> the requesting clients (adversary)
//
// Arbiter enforces mutual exclusion of grants (TRUE):
//   -atl "<arb>G{g1 + g2 <= 1}"
// =====================================================================

int main() {
    int g1 = 0;   // grant line client 1
    int g2 = 0;   // grant line client 2
    while (true) {
        int r1 = input("env");    // request from client 1 (adversary)
        int r2 = input("env");    // request from client 2 (adversary)
        int grant = input("arb"); // arbiter: 0 none, 1 client1, 2 client2
        g1 = 0;
        g2 = 0;
        if (grant == 1) { g1 = 1; }
        if (grant == 2) { g2 = 1; }
    }
}
