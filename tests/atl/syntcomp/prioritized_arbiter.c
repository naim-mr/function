// =====================================================================
// Prioritized Arbiter -- reactive synthesis benchmark (SYNTCOMP)
// ---------------------------------------------------------------------
// Source : SYNTCOMP, "Prioritized Arbiter".
//   https://github.com/SYNTCOMP/benchmarks/tree/master/tlsf/prioritized_arbiter/parametric
// Original TLSF specification: see prioritized_arbiter.tlsf
// ---------------------------------------------------------------------
// Like the simple arbiter, but with a privileged "master" client whose
// grant must never coincide with a standard grant. We check the safety
// invariant: mutual exclusion across ALL grants (standards + master).
//
//   agent "arb" = input("arb")  -> the arbiter (coalition, angelic)
//   agent "env" = input("env")  -> the requesting clients (adversary)
//
//   -atl "<arb>G{g1 + g2 + gm <= 1}"
// =====================================================================

int main() {
    int g1 = 0;
    int g2 = 0;
    int gm = 0;   // master grant
    while (true) {
        int r1 = input("env");    // standard request 1 (adversary)
        int r2 = input("env");    // standard request 2 (adversary)
        int rm = input("env");    // master request (adversary)
        int grant = input("arb"); // 0 none, 1 client1, 2 client2, 3 master
        g1 = 0;
        g2 = 0;
        gm = 0;
        if (grant == 1) { g1 = 1; }
        if (grant == 2) { g2 = 1; }
        if (grant == 3) { gm = 1; }
    }
}
