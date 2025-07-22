typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    
    int a;
    int b;
    int r;
    a = input();
    b = input();
    
    while (b > 0) {
        r =  rand();
        b = a - 1 - r;
        a = a - 1 - r;
    }
    
    return 0;
}