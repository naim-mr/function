// *************************************************************
//
// Original source code by Byron Cook & Eric Koskinen, July 2010
// https://github.com/ultimate-pa/ultimate/blob/dev/trunk/examples/LTL/koskinen/branching-benchmarks/win4.c
//
//
// Modified by Samuel Ueltschi for FuncTion 
//
// Property: AF AG WItemsNum >= 1
//
// -ctl_str "AF{AG{WItemsNum >= 1}}"
//
void main() {
    int WItemsNum = input("env");
    
    while(1) {
        while(WItemsNum <= 5 || input("adv") == 1) {
               if (WItemsNum <= 5) {
                   WItemsNum++;
               } else {
                   WItemsNum++;
               }
        }
        while(WItemsNum > 2) {
             WItemsNum--;
        }
    }

    while(1) {}
}
    
