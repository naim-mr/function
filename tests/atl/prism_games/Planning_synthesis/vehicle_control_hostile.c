// =====================================================================
// Safe Vehicle Control in a Hostile Environment -- PRISM (de-prob., game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Probabilistically safe vehicle control in a
//          hostile environment". https://www.prismmodelchecker.org/casestudies/
// Original model description: see vehicle_control_hostile.txt
// ---------------------------------------------------------------------
// A vehicle drives toward a goal across terrain where a hostile environment
// places threats. Each step the vehicle picks a lane; the environment picks a
// lane to threaten. Driving into the threatened lane is a hit; otherwise the
// vehicle advances. Threats are adversarial but bounded, so the goal remains
// reachable. The vehicle has a strategy that is both safe and progressing.
//
//   agent "veh" = input("veh")  -> vehicle controller (coalition, angelic)
//   agent "env" = input("env")  -> hostile environment (adversary, bounded)
//
// The vehicle is never hit (TRUE):      -atl "<veh>G{hit == 0}"
// The vehicle reaches the goal (TRUE):  -atl "<veh>F{pos >= goal}"
// =====================================================================

int main() {
    int pos = 0;                // progress toward the goal
    int lane = 0;               // chosen lane this step
    int hit = 0;                // vehicle hit a threat this step?
    int goal = input("env");    // goal distance: arbitrary, not fixed in advance
    int budget = input("env");  // adversary-chosen FINITE threat bound, NOT fixed in advance:
                                // the proof must hold for any value (surrogate for "finitely many").
    while (pos < goal) {
        int threat = -1;             // -1 = no threat
        // the hostile env threatens a lane only while the bounded budget remains
        if (budget > 0) { threat = input("env"); }   // threatens lane 0 or 1
        int steer = input("veh");                      // vehicle chooses lane (0 / 1)
        lane = 0;
        if (steer == 1) { lane = 1; }
        hit = 0;
        if (threat == lane) { hit = 1; budget = budget - 1; }
        else { pos = pos + 1; }
    }
}


