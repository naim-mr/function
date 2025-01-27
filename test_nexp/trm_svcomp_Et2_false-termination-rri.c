typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    
    int a;
    int b;
    int r;
    a = rand;
    b = rand;
    
    while (b > 0) {
        r =  input;
        
        b = a - 1 - r;
        a = a - 1 - r;
    }
    
    return 0;
}