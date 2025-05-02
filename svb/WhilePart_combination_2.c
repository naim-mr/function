typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    i = rand;                   
    
    while (i > 5) {
        if (i < 10) {
            i = i-1;
        }
    }
    
    return 0;
}
