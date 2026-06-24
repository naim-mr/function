// =====================================================================
// Robot Coordination -- PRISM-games case study (de-probabilised rPATL)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Robot coordination".
//   https://www.prismmodelchecker.org/games/casestudies/robot_coordination.php
//   Tool/papers: https://www.prismmodelchecker.org/games/
// Original model description: see robot_coordination.txt
// ---------------------------------------------------------------------
// Two robots move along a corridor toward their goal cells (x1,x2 >= 4).
// Each round a robot issues a commanded step; the "slippery" environment may
// push a robot back. We model the actuator as STRONGER than the disturbance:
// a commanded step is +2, a slip is -1, so a pushing robot nets +1 per round
// whatever the environment does. This is the de-probabilisation of "a move
// succeeds with prob > 1/2": the controllable displacement dominates the
// adversarial slip, so progress is guaranteed (a purely cancelling adversary
// would otherwise stall the robots forever and the goal would be unreachable).
//
//   agents "r1","r2" = input("r1"), input("r2")  -> robots (coalition)
//   agent  "env"     = input("env")              -> slips (adversary)
//
// The coalition brings BOTH robots to the goal (TRUE):
//   -atl "<r1,r2>F{AND{x1 >= 4}{x2 >= 4}}"
// =====================================================================

int main() {
    int x1 = 0;            // position of robot 1
    int x2 = 0;            // position of robot 2
    while (1) {
        int s1 = input("env");   // env tries to slip robot 1 back
        int s2 = input("env");   // env tries to slip robot 2 back
        int m1 = input("r1");    // robot 1 commanded step?
        int m2 = input("r2");    // robot 2 commanded step?
        if (m1 == 1) { x1 = x1 + 2; }   // actuator step (dominates the slip)
        if (s1 == 1) { x1 = x1 - 1; }   // slip
        if (m2 == 1) { x2 = x2 + 2; }
        if (s2 == 1) { x2 = x2 - 1; }
    }
}
