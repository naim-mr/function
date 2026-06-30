// =====================================================================
// RFID Goods-Management Attack-Defence -- PRISM-games case study
// ---------------------------------------------------------------------
// Source : Z. Aslanyan, F. Nielson, D. Parker,
//   "Quantitative Verification and Synthesis of Attack-Defence Scenarios",
//   CSF 2016 (attack-defence trees -> stochastic two-player games).
// Original model description: see rfid_attack_defence.txt
// ---------------------------------------------------------------------
// An attack-defence TREE for an RFID warehouse goods-management system, compiled
// to a two-player game: attacker (coalition) vs defender (adversary). To remove
// the RFID tags the attacker must, in sequence (sequential conjunction):
//   phase 1: get into the premises   (route: climb the fence OR enter the gate)
//   phase 2: get into the warehouse  (route: the door OR the loading dock)
//   phase 3: evade the cameras       (route: laser OR video-loop, vs guards)
// Each phase offers alternative attacker routes (OR); the defender deploys a
// countermeasure that blocks ONE route per phase (barbed wire, biometric
// sensors, security cameras/guards). The attacker breaches if it completes all
// phases via routes the defender does not block.
//
// The paper reports a maximum attack-success probability of 0.41 (< 1, due to
// the probabilistic success of basic actions). De-probabilised (deterministic
// routes), the question becomes: can the attacker find an unblocked path?
// With more routes than the defender can block per phase, it can -> TRUE: the
// system is open to attack (the qualitative core of "success probability > 0").
//
//   agent "atk" = input("atk")  -> attacker: route choices (coalition)
//   agent "def" = input("def")  -> defender: countermeasures (adversary)
//
// The attacker breaches the warehouse (TRUE):
//   -atl "<atk>F{breached == 1}"
// =====================================================================

int main() {
    int phase = 0;         // attack phases completed (need 3)
    int breached = 0;
    while (phase < 3) {
        int route = input("atk");   // attacker picks a route for this phase (0 / 1)
        int block = input("def");   // defender blocks one route this phase (0 / 1)
        if (route != block) {
            phase = phase + 1;       // route not blocked -> phase completed
        }
        // if the chosen route is blocked, the attacker retries (OR: alternative route)
    }
    breached = 1;          // all three phases completed -> tags removed
}
