// =====================================================================
// Non-Repudiation Protocol -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Non-repudiation protocol" (Markowitch-Roggeman).
//   https://www.prismmodelchecker.org/games/casestudies/non_repudiation.php
// Original model description: see non_repudiation.txt
// ---------------------------------------------------------------------
// A fair-exchange / non-repudiation protocol between an originator (sender)
// and a recipient. Fairness must hold: the protocol must never reach a state
// where the recipient holds the message while the originator holds NO receipt
// (non-repudiation-of-receipt evidence). The originator controls when to
// release the message; the recipient (adversary) may withhold the receipt.
//
//   agent "orig" = input("orig")  -> originator (coalition, angelic)
//   agent "recv" = input("recv")  -> recipient  (adversary)
//
// The originator preserves fairness forever (TRUE):
//   -atl "<orig>G{fair == 1}"
// =====================================================================

int main() {
    int msg = 0;           // recipient has obtained the message?
    int nrr = 0;           // originator holds the receipt (NRR evidence)?
    int fair = 1;          // fairness invariant currently holds?
    while (1) {
        int ack  = input("recv");   // recipient sends the receipt?
        int send = input("orig");   // originator releases the message now?
        if (ack == 1) { nrr = 1; }
        // the originator releases the message only once the receipt is in
        if (send == 1) { if (nrr == 1) { msg = 1; } }
        fair = 1;
        if (msg == 1 && nrr == 0) { fair = 0; }
    }
}
