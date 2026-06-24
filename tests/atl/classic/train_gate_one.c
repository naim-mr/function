// =====================================================================
// Train Gate Controller -- classic ATL example
// ---------------------------------------------------------------------
// Source : R. Alur, T. A. Henzinger, O. Kupferman,
//          "Alternating-Time Temporal Logic", JACM 49(5), 2002.
//          https://www.cis.upenn.edu/~alur/Jacm02.pdf  (Sect. 2, running example)
// Original concurrent game structure: see originals/train_gate.cgs.txt
// ---------------------------------------------------------------------
// Two trains may request access to a shared tunnel; a controller decides
// whom to admit. The controller has a strategy to keep mutual exclusion
// of the tunnel forever, whatever the trains request.
//
//   agent "controller" = input("controller")  -> coalition (angelic)
//   agents "train1"/"train2"                   -> environment (adversary)
//
//       Property: < >G{OR{q != 3}{AND{q == 3}{<ctrl >X{q != 3}}}}

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
