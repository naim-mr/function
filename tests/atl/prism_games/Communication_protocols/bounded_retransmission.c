// =====================================================================
// Bounded Retransmission Protocol -- PRISM case study (de-prob., game cast)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "Bounded retransmission protocol".
//      https://www.prismmodelchecker.org/casestudies/brp.php
// Original model description: see bounded_retransmission.txt
// ---------------------------------------------------------------------
// A sender transmits a file of N chunks over a lossy channel. Each chunk may
// be retransmitted at most MAX times; if it is STILL lost after MAX
// retransmissions the protocol ABORTS and the file is NOT delivered. This is
// the whole point of the BRP: delivery is bounded, so a channel that keeps
// dropping a single chunk (MAX+1 times) forces an abort. Hence the sender
// CANNOT guarantee delivery against a worst-case channel.
//
//   agent "snd" = input("snd")  -> sender (coalition, angelic)
//   agent "env" = input("env")  -> lossy channel (adversary)
//
// Can the sender SURELY deliver the whole file? Expected UNKNOWN -- a soundness
// witness (the quantitative original has P[abort] > 0): a channel that exhausts
// the retransmission bound on one chunk aborts the transfer.
//   -atl "<snd>F{delivered >= chunks}"
// =====================================================================

int main() {
    int delivered = 0;            // chunks acknowledged so far
    int aborted   = 0;            // transfer given up (retransmission bound exhausted)?
    int chunks = input("env");    // file size N: arbitrary, not fixed in advance
    int max    = input("env");    // per-chunk retransmission bound: arbitrary, not fixed
    while (delivered < chunks && aborted == 0) {
        int retries = max;        // fresh retransmission budget for THIS chunk
        int acked   = 0;
        while (acked == 0 && aborted == 0) {
            int send = input("snd");         // sender (re)transmits the chunk?
            if (send == 1) {
                int drop = input("env");     // the channel may drop this (re)transmission
                if (drop == 1) {
                    if (retries > 0) { retries = retries - 1; }  // retransmit
                    else { aborted = 1; }                        // bound exhausted -> abort
                } else {
                    acked = 1;                                   // chunk delivered + acked
                }
            }
        }
        if (acked == 1) { delivered = delivered + 1; }
    }
}
