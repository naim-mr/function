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
//
// Scheduler completes the job in time (TRUE):
////   -atl "<sched>F{done == 1}"
//   -atl "<sched>F{done == 1 && time <= budget}"
// =====================================================================

int main() {
    int remaining = 4;     // tasks left to schedule
    int time = 0;          // elapsed time
    int budget = 12;       // deadline
    int done = 0;
    while (remaining > 0) {
        int assign = input("sched");  // schedule a task on a fast(1)/slow lane
        int jitter = input("env");    // environment adds delay 0..1
        if (jitter < 0) { jitter = 0; }
        if (jitter > 1) { jitter = 1; }
        if (assign == 1) {
            remaining = remaining - 1;
            time = time + 2 + jitter;   // worst case 3 per task, 4 tasks <= 12
        }
    }
    if (remaining == 0 && time <= budget) { done = 1; }
    while (1) {}
}
