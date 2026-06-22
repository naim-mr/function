// =====================================================================
// Intrusion Detection -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Intrusion detection policies".
//   https://www.prismmodelchecker.org/games/casestudies/ids.php
// Original model description: see intrusion_detection.txt
// ---------------------------------------------------------------------
// A defender runs a system facing an attacker who repeatedly probes it.
// Each round the attacker may launch an attack; the defender may patch /
// block. The defender has a strategy to keep the system uncompromised.
//
//   agent "def" = input("def")  -> defender (coalition, angelic)
//   agent "atk" = input("atk")  -> attacker (adversary)
//
// Defender keeps the system safe forever (TRUE):
//   -atl "<def>G{compromised == 0}"
// =====================================================================

int main() {
    int compromised = 0;
    int exposure = 0;      // accumulated unpatched exposure
    while (true) {
        int attack = input("atk");   // attacker launches an attack?
        int patch = input("def");    // defender patches this round?
        if (attack == 1) { exposure = exposure + 1; }
        if (patch == 1) { exposure = 0; }
        // the system is compromised only if exposure is left to build up
        if (exposure >= 1) {
            if (patch == 0) { compromised = 1; }
        }
        if (patch == 1) { compromised = 0; }
    }
}
