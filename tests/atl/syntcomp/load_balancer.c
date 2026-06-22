// =====================================================================
// Load Balancer -- reactive synthesis benchmark (SYNTCOMP)
// ---------------------------------------------------------------------
// Source : SYNTCOMP, "Parameterized Load Balancer"
//          (generalized version of the Acacia+ benchmark).
//   https://github.com/SYNTCOMP/benchmarks/tree/master/tlsf/load_balancer/parametric
// Original TLSF specification: see load_balancer.tlsf
// ---------------------------------------------------------------------
// A load balancer dispatches incoming requests to n servers; it may only
// dispatch when the system is idle and never assigns the same job twice.
// We check the safety invariant: at most one server is granted a job at a
// time (mutual exclusion of the grant lines).
//
//   agent "lb"  = input("lb")   -> the load balancer (coalition, angelic)
//   agent "env" = input("env")  -> incoming requests / idle signal (adversary)
//
//   -atl "<lb>G{g1 + g2 <= 1}"
// =====================================================================

int main() {
    int g1 = 0;
    int g2 = 0;
    while (true) {
        int idle = input("env");      // is the system idle? (adversary)
        int req1 = input("env");      // request for server 1 (adversary)
        int req2 = input("env");      // request for server 2 (adversary)
        int dispatch = input("lb");   // 0 none, 1 server1, 2 server2
        g1 = 0;
        g2 = 0;
        if (idle != 0) {
            if (dispatch == 1) { if (req1 != 0) { g1 = 1; } }
            if (dispatch == 2) { if (req2 != 0) { g2 = 1; } }
        }
    }
}
