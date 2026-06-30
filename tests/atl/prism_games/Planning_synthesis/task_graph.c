// =====================================================================
// Task-Graph Scheduling -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Task-graph scheduling".
//   https://www.prismmodelchecker.org/games/casestudies/task_graph.php
// Original model description: see task_graph.txt
// ---------------------------------------------------------------------
// A scheduler assigns tasks to processors to complete a job by a deadline.
// Task durations vary (environment). The scheduler can guarantee finishing
// all tasks within the time budget.
//
//   agent "sched" = input("sched")  -> the scheduler (coalition, angelic)
//   agent "env"   = input("env")    -> task duration jitter (adversary)
// In the prism original game, the objective was to verify the minimal budget that the scheduler can ensure
// We cannot express such property.
// Scheduler completes the job in time (TRUE):
////   -atl "<sched>F{done == 1}"
//   -atl "<sched>F{done == 1 && time <= budget}"
// =====================================================================

int main() {
    int n = input("env");      // number of tasks: arbitrary, not fixed in advance
    if (n < 0) n = 0;
    int remaining = n;     // tasks left to schedule
    int time = 0;          // elapsed time
    int budget = 3 * n;    // deadline: worst case 3 time units per task
    int done = 0;
    while (remaining > 0) {
        int assign = input("sched");  // schedule a task on a fast(1)/slow lane
        int jitter = input("env");    // environment adds delay 0..1
        if (jitter < 0) { jitter = 0; }
        if (jitter > 1) { jitter = 1; }
        if (assign == 1) {
            remaining = remaining - 1;
            time = time + 2 + jitter;   // worst case 3 per task, n tasks <= 3*n
        }
    }
    if (remaining == 0 && time <= budget) {
        done = 1;
    }
}
