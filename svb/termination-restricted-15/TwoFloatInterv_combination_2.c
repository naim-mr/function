typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    i = rand;                   
    
    while (i > 0 && i < 50) {
        if (i < 20) {
            i = i-1;
        }
        if (i > 10) {
            i = i+1;
        }
        if (30 <= i && i <= 40) {
            i = i-1;
        }
        
    }
    
    return 0;
}
