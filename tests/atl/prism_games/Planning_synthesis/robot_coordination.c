// =====================================================================
// Robot Coordination -- PRISM-games case study (de-probabilised rPATL)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Robot coordination".
//    https://www.prismmodelchecker.org/games/casestudies/robot_coordination.php
//   Tool/papers: https://www.prismmodelchecker.org/games/
// Original model description: see robot_coordination.txt
// ---------------------------------------------------------------------
// Two robots navigate a 2D GRID toward the far corner (goal,goal), starting
// from (0,0). Each robot has coordinates (x,y) and commands a step along each
// axis; the "slippery" environment may push a robot back on either axis. We
// model the actuator as STRONGER than the disturbance: a commanded step is +2,
// a slip is -1, so a pushing robot nets +1 per axis per round whatever the
// environment does. This is the de-probabilisation of "a move succeeds with
// prob > 1/2": the controllable displacement dominates the adversarial slip,
// so progress on each axis is guaranteed (a purely cancelling adversary would
// otherwise stall the robots forever and the goal would be unreachable).
//
//   agents "r1","r2" = input("r1"), input("r2")  -> robots (coalition)
//   agent  "env"     = input("env")              -> slips (adversary)
//
// The coalition brings BOTH robots to the goal corner (TRUE):
//   -atl "<r1,r2>F{AND{AND{x1 >= goal}{y1 >= goal}}{AND{x2 >= goal}{y2 >= goal}}}"
// =====================================================================

int main() {
    int goal = input("env");   // goal corner coordinate: arbitrary, not fixed in advance
    int x1 = 0; int y1 = 0;    // robot 1 on the grid
    int x2 = 0; int y2 = 0;    // robot 2 on the grid
    while (1) {
        int sx1 = input("env");  // env tries to slip robot 1 back on x
        int sy1 = input("env");  // env tries to slip robot 1 back on y
        int sx2 = input("env");  // env tries to slip robot 2 back on x
        int sy2 = input("env");  // env tries to slip robot 2 back on y
        int ax1 = input("r1");   // robot 1 commanded x-step?
        int ay1 = input("r1");   // robot 1 commanded y-step?
        int ax2 = input("r2");   // robot 2 commanded x-step?
        int ay2 = input("r2");   // robot 2 commanded y-step?
        if (ax1 == 1) { x1 = x1 + 2; }   // actuator step (dominates the slip)
        if (sx1 == 1) { x1 = x1 - 1; }   // slip
        if (ay1 == 1) { y1 = y1 + 2; }
        if (sy1 == 1) { y1 = y1 - 1; }
        if (ax2 == 1) { x2 = x2 + 2; }
        if (sx2 == 1) { x2 = x2 - 1; }
        if (ay2 == 1) { y2 = y2 + 2; }
        if (sy2 == 1) { y2 = y2 - 1; }
    }
}
