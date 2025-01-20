typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int t;
    i = rand;                   
    j = rand;                   
    t = 0;
    
    while (i > 0 && j > 0) {
        if (i < j) {
            t = i;
            i = j;
            j = t;
        } else {
            if (i > j) {
                j = i;
            } else {
                i = i-1;
            }
        }
    }
    
    return 0;
}
