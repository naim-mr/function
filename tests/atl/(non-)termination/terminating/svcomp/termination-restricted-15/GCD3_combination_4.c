typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int tmp;
    int xtmp;
    x = input("adv");
    y = input("adv");
    
    while(y > 0 && x > 0) {
        tmp = y;
        xtmp = x;
        
        if(y == 0) {
            y = y;
        }
        else {
            if(y < 0) {
                xtmp = -xtmp;
            }
        }
        if(xtmp > 0) {
            while(xtmp>=y) {
                xtmp = xtmp - y;
            }
            y = xtmp;
        } else {
            while(xtmp < 0) {
                xtmp = xtmp - y;
            }
            y = xtmp;
        }
        
        x = tmp;
    }
    
    return 0;
}
