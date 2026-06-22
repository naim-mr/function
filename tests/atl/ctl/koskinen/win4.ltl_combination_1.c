//#Safe
//@ ltl invariant positive: <>[]AP(WItemsNum >= 1);

extern int input("env") __attribute__ ((__noreturn__));
int WItemsNum;
void main() {
    
    while(1) {
        while(WItemsNum <= 5 || input("env") == 1) {
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
    
