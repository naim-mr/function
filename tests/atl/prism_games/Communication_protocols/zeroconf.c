// =====================================================================
// IPv4 Zeroconf Address Allocation -- PRISM case study (de-prob., game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "IPv4 Zeroconf protocol".
//   https://www.prismmodelchecker.org/casestudies/zeroconf.php
// Original model description: see zeroconf.txt
// ---------------------------------------------------------------------
// A host joining a network self-assigns an IP address: it probes a candidate
// address and, if no other host claims it, configures. The network may raise
// an address conflict, but only a bounded number of times; the host then
// picks another candidate. The host eventually configures an address.
//
//   agent "host" = input("host")  -> joining host (coalition, angelic)
//   agent "env"  = input("env")   -> address conflicts (adversary, bounded)
//
// The host eventually configures an address (TRUE):
//   -atl "<host>F{configured == 1}"
// =====================================================================

int main() {
    int configured = 0;    // host has acquired an address?
    int conflicts = input("env");  // adversary-chosen FINITE conflict bound, NOT fixed in advance
                                   // (any value -- e.g. RFC 3927 MAX_CONFLICTS = 10 -- and beyond):
                                   // the proof must hold for an arbitrary finite number of conflicts.
    while (configured == 0) {
        int collide = 0;
        // the network can raise a conflict only while the bound is not exhausted
        if (conflicts > 0) { collide = input("env"); }   // another host claims the address?
        int probe = input("host");                        // host probes a candidate address?
        if (probe == 1) {
            if (collide == 1) { conflicts = conflicts - 1; }  // conflict -> pick another address
            else { configured = 1; }                          // no conflict -> configured
        }
    }
}
