typedef enum { false, true } bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    i = rand;                   
    
    while (true) {
        if (i > 0) {
            i = i-1;
        }
        if (i < 0) {
            i = i+1;
        }
    }
    
    return 0;
}
