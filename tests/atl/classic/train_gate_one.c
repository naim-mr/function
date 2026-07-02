// =====================================================================
// Train Gate Controller -- classic ATL example
// ---------------------------------------------------------------------
// Source : R. Alur, T. A. Henzinger, O. Kupferman,
//          "Alternating-Time Temporal Logic", JACM 49(5), 2002.
//          https://www.cis.upenn.edu/~alur/Jacm02.pdf  (Sect. 2, running example)
// Original concurrent game structure: see originals/train_gate.cgs.txt
// ---------------------------------------------------------------------
// AHK Example 2.2: a SINGLE train and a gate controller, turn-based.
// State q encodes the four locations of the game structure:
//     q == 0 : out_of_gate              (q0, train outside)
//     q == 1 : out_of_gate + request    (q1, train asked to enter)
//     q == 2 : out_of_gate + grant      (q2, controller granted)
//     q == 3 : in_gate                  (q3, train in the gate)
//
//   agent "train" = input("train")  -> moves at q0, q2   (angelic / coalition)
//   agent "ctrl"  = input("ctrl")   -> moves at q1, q3
//
// Implication is not primitive in the ATL property grammar, so we encode
//     p -> q    as    OR{ NOT{p} }{ q }      (i.e. (not p) or q).
//
// Properties of the paper  (in_gate == "q == 3"):
//
//  (1) the train ALONE cannot force entry           -- expected UNKNOWN (soundness):
//        <train>F{q == 3}
//
//  (2) train and controller TOGETHER reach the gate -- expected TRUE:
//        <train,ctrl>F{q == 3}
//
//  (3) the controller can keep the train out forever -- expected TRUE:
//        <ctrl>G{q != 3}
//  P1: Whenever the train is out of the gate and does not have a grant to enter the gate,
//      the controller can prevent it from entering the gate:
//       <>G{OR{q==0}{<ctlr>G{out_of_gate:true}}}
//
//  P2: Whenever the train is out of the gate, the controller cannot force it to enter the
//        gate:
//      <>G{OR{in_gate:true}{NOT{<train>F{in_gate:true}}}
//  P3:Whenever the train is out of the gate, the train and the controller can cooperate
//  so that the train will enter the gate
//        <>G{OR{in_gate:true}{<ctrl,train>F{in_gate:true}}}
//  P4:Whenever the train is out of the gate, it can eventually request a grant for
//  entering the gate, in which case the controller decides whether the grant is
//  given or not: 
//    <>G{OR{in_gate:true}{AND{<train>F{AND{request:true}{<ctrl>F{grant:true}}}{NOT{<train>F{q==0 || q== 1|| q==3}}}}}
// =====================================================================

int main() {
    int q = 0;
    out_of_gate:
    while (1) {
        if (q == 0){
            out_of_gate:
            if (input("train") > 0){
               q = 1;
            }  
        } else if (q == 1){
            out_of_gate:
            request:
            if (input("ctrl") > 0){
                q = 2;   
            }
        } else if (q == 2){
            out_of_gate:
            grant:
            if (input("train") > 0){
               q = 3;
            } else {
               q = 0;
            }
        }else if (q == 3){
             in_gate:
             if (input("ctrl") > 0){
                q = 0;   
            }
        }
    }
}
