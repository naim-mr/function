// =====================================================================
// Intrusion Detection -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Intrusion detection policies".
//   https://www.prismmodelchecker.org/casestudies/ids.php
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
    int attack_treshold;
    while (1) {
        int attack = input("atk");   // attacker launches an attack?
        int patch = input("def");    // defender patches this round?
        if (attack >= 0) { exposure = exposure + 1; }
        if (patch >= 0) { exposure = exposure + 1;  }
        if (exposure > attack_treshold){
            compromised = 1;
        }
    }
}
