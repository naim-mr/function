// =====================================================================
// Bounded Retransmission Protocol -- PRISM case study (de-prob., game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Bounded retransmission protocol".
//   https://www.prismmodelchecker.org/casestudies/brp.php
// Original model description: see bounded_retransmission.txt
// ---------------------------------------------------------------------
// A sender transmits a file of N chunks over a lossy channel. Each chunk may
// be lost in transit; the protocol retransmits, but only a bounded number of
// times. The sender delivers the whole file whatever the (bounded) losses.
//
//   agent "snd" = input("snd")  -> sender (coalition, angelic)
//   agent "env" = input("env")  -> lossy channel (adversary, bounded)
//
// The sender delivers the whole file of N chunks (TRUE):
//   -atl "<snd>F{delivered >= chunks}"
// =====================================================================

int main() {
    int delivered = 0;          // chunks acknowledged
    int chunks = input("env");  // file size N: arbitrary, not fixed in advance
    int losses = input("env");  // adversary-chosen FINITE loss budget, NOT fixed in advance:
                                // the proof must hold for any value -> well-founded order over an
                                // arbitrary finite count (surrogate for "finitely many losses").
    while (delivered < chunks) {
        int send = input("snd");   // sender transmits the next chunk?
        if (send == 1) {
            int drop = 0;
            // the channel can only drop a chunk while it still has loss budget;
            // once the budget is spent the channel is reliable
            if (losses > 0) { drop = input("env"); }
            if (drop == 1) {
                losses = losses - 1;        // chunk lost -> retransmit (not delivered)
            } else {
                delivered = delivered + 1;  // chunk delivered
            }
        }
    }
 
}
