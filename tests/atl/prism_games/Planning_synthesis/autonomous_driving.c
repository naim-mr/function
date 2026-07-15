// =====================================================================
// Autonomous Urban Driving -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Autonomous urban driving".
//   https://www.prismmodelchecker.org/games/
// Original model description: see autonomous_driving.txt
// ---------------------------------------------------------------------
// An autonomous car drives along a route to its destination. The urban
// environment may present hazards (pedestrians / obstacles) ahead. The car
// may advance or yield (brake). Advancing into a hazard causes a collision;
// yielding is always safe. Hazards are adversarial but bounded (the original
// probabilistic hazards collapse to a finite demonic budget).
//
//   agent "car" = input("car")  -> the vehicle controller (coalition, angelic)
//   agent "env" = input("env")  -> urban hazards (adversary, bounded)
//
// The car never collides (TRUE):    -atl "<car>G{crash == 0}"
// The car always reach its goal (TRUE):  -atl "<car>G{<car>F{pos >= goal}}"
// =====================================================================

int main() {
    
                 // collision occurred this step?
    
                                // the proof must hold for any value (surrogate for "finitely many").
    while(1){
        int goal = input("env");    // route length (goal distance): arbitrary, not fixed in advance
        int budget = input("env");  // adversary-chosen FINITE hazard bound, NOT fixed in advance:
                                // the proof must hold for any value (surrogate for "finitely many").                 // distance covered along the route
        while (goal > 0) {
            int hazard = 0;
            // a genuine hazard appears only while the bounded budget remains
            if (budget > 0) { hazard = input("env"); }   // a hazard appears ahead?
            int act = input("car");                       // car: <= 0 stop (safe), > 0 advance
            if (hazard >= 1) {
                if (act >= 1) { return 1}   // advancing into a hazard -> collision
                budget = budget - 1;           // the hazard passes
            } else {
                if (act >= 1) { goal = goal - 1 }
            }
        }
        win:
    }
}


