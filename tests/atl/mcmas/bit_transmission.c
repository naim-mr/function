// =====================================================================
// Bit Transmission Problem -- MCMAS benchmark
// ---------------------------------------------------------------------
// Source : MCMAS model checker (Lomuscio et al.), standard ISPL example.
//   https://vas.doc.ic.ac.uk/software/mcmas/
//   Paper: "MCMAS: an open-source model checker...", IJSTTT 2017,
//          https://link.springer.com/article/10.1007/s10009-015-0378-x
// Original model description: see bit_transmission.txt
// ---------------------------------------------------------------------
// A Sender keeps sending a bit to a Receiver over a faulty channel until it
// gets an acknowledgement. The faulty channel is adversarial: it may drop a
// message. The COALITION {sender, channel} can guarantee delivery+ack
// (the genuine single-agent property of the original model is EPISTEMIC --
// "the sender comes to KNOW that the receiver received" -- and needs K
// operators that a  encoding cannot epurely numericxpress; see .txt).
//
//   agents "sender","chan" = input("sender"), input("chan")  -> coalition
//   (no separate adversary: the faulty channel is the only environment)
//
//   -atl "<sender,chan>F{ack == 1}"
// =====================================================================

int main() {
    int recv = 0;          // receiver got the bit?
    int ack = 0;           // sender got the acknowledgement?
    while (ack == 0) {      
        int send = input("sender");   // sender (re)transmits the bit?
        int deliver = input("chan");  // channel delivers this round?
        if (send == 1) { if (deliver == 1) { recv = 1; } }
        if (recv == 1) { if (deliver == 1) { ack = 1; } }
    }
}
