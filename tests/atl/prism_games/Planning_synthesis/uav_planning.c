// =====================================================================
// Human-in-the-Loop UAV Mission Planning -- PRISM-games (de-probabilised)
// ---------------------------------------------------------------------
// Source : L. Feng, C. Wiltsche, L. Humphrey, U. Topcu,
//   "Controller Synthesis for Autonomous Systems Interacting with Human
//    Operators", ICCPS 2015 (stochastic two-player game version).
// Original model description: see uav_planning.txt
// ---------------------------------------------------------------------
// A UAV performs an ISR mission over a road network of waypoints. It is a
// two-player game: Player 1 = UAV autonomy (controllable), Player 2 = human
// operator (worst-case). The autonomy flies the route, but at CHECKPOINTS the
// operator chooses the road -- and could route the UAV in a loop forever
// (w2,w6,w5,...), preventing mission completion. The paper avoids this with a
// DELEGATION probability pdel > 0: the operator must occasionally delegate
// routing to the UAV. We de-probabilise pdel as a BOUNDED number of operator
// diversions (after which it delegates), so the UAV can make progress.
// A diversion may route the UAV through a Restricted Operating Zone (ROZ).
//
//   agent "uav" = input("uav")  -> UAV autonomy (coalition, angelic)
//   agent "op"  = input("op")   -> human operator (adversary): routing + sizes
//
// Mission completion -- the UAV covers the route (TRUE, thanks to delegation):
//   -atl "<uav>F{wp >= goal}"
// ROZ avoidance -- the UAV avoids ALL restricted zones:
//   -atl "<uav>G{roz == 0}"   (expected UNKNOWN: a worst-case operator can route
//                              through a ROZ during a diversion; the paper only
//                              MINIMISES ROZ visits -- a Pareto trade-off, not 0.)
// =====================================================================

int main() {
    int goal = input("op");      // waypoints to cover (mission length): arbitrary, not fixed
    int divert_max = input("op");   // delegation surrogate: bounded number of operator diversions
                                 // (with pdel > 0 the operator must eventually delegate, so it
                                 //  cannot loop the UAV forever)
    int wp = 0;                  // waypoints covered so far
    int roz = 0;                 // currently inside a restricted operating zone?
    while (wp < goal) {
        int divert = input("op");    // operator's choice this round: divert the UAV?
        roz = 0;
        if (divert == 1 && divert_max > 0) {
            divert_max = divert_max - 1;   // diversion consumes the bounded delegation budget (no progress)
            roz = input("op");       // operator chooses whether the diverting road crosses a ROZ
            if (roz != 1) { roz = 0; }   // normalise to a 0/1 flag
        } else {
            int fly = input("uav");  // delegated / budget spent: UAV advances on a safe road
            wp = wp + 1;             // and reaches the next waypoint, avoiding ROZs
        }
    }
}
