// =====================================================================
// ASW Fair Exchange Protocol -- PRISM case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM case studies, "ASW fair exchange protocol" (Asokan,
//          Shoup, Waidner). https://www.prismmodelchecker.org/casestudies/
// Original model description: see asw_fair_exchange.txt
// ---------------------------------------------------------------------
// Two parties exchange signatures with the help of a trusted third party
// (TTP). Fairness: an honest party must never end up having released its own
// signature while not holding the other's. If the peer aborts, the honest
// party invokes the TTP to recover the missing signature.
//
//   agent "orig" = input("orig")  -> honest party (coalition, angelic)
//   agent "resp" = input("resp")  -> peer (adversary)
//
// The honest party preserves fairness forever (TRUE):
//   -atl "<orig>G{unfair == 0}"
// =====================================================================

int main() {
    int have = 0;          // honest party holds the peer's signature?
    int gave = 0;          // honest party has released its own signature?
    int unfair = 0;        // fairness currently violated?
    while (1) {
        int act_r = input("resp");   // peer: 1 sends its signature, 2 aborts
        int act_o = input("orig");   // honest: 0 wait, 1 send own sig, 2 invoke TTP
        if (act_r == 1) { have = 1; }
        if (act_o == 1) { gave = 1; }
        // TTP recovery: if the honest party already committed but got nothing back
        if (act_o == 2) { if (gave == 1) { have = 1; } }
        unfair = 0;
        if (gave == 1 && have == 0) { unfair = 1; }
    }
}
