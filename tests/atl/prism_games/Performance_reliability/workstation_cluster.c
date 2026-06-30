// =====================================================================
// Workstation Cluster -- PRISM case study (de-probabilised, game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Workstation cluster"
//          (Haverkort, Hermanns & Katoen).
//   https://www.prismmodelchecker.org/casestudies/cluster.php
// Original model description: see workstation_cluster.txt
// ---------------------------------------------------------------------
// Two sub-clusters of N workstations each provide a service; workstations fail
// and a repair unit restores them. Quality of service requires at least N
// operational workstations across the two sub-clusters. The repair unit keeps
// QoS satisfied whatever the failures. The sub-cluster size N and the QoS
// threshold are arbitrary -- NOT fixed in advance.
//
//   agent "rep" = input("rep")  -> repair unit (coalition, angelic)
//   agent "env" = input("env")  -> workstation failures + sizes (adversary)
//
// The repair unit keeps QoS satisfied forever (TRUE):
//   -atl "<rep>G{qos == 1}"
// =====================================================================

int main() {
    int n = input("env");      // workstations per sub-cluster: arbitrary, not fixed
    if (n < 1) n = 1;          // each sub-cluster has at least one workstation
    int left = n;              // operational workstations in the left sub-cluster
    int right = n;             // operational workstations in the right sub-cluster
    int qos = 1;               // minimum quality of service met?
    while (1) {
        int fail   = input("env");   // env fails one: 1 -> left, 2 -> right
        int repair = input("rep");   // repair unit restores one: 1 -> left, 2 -> right
        if (fail == 1) { if (left > 0) { left = left - 1; } }
        if (fail == 2) { if (right > 0) { right = right - 1; } }
        if (repair == 1) { if (left < n) { left = left + 1; } }
        if (repair == 2) { if (right < n) { right = right + 1; } }
        qos = 1;
        if (left + right < n) { qos = 0; }   // below the minimum service level (N)
    }
}
