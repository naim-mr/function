typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    // x = __VERIFIER_nondet_int();
    // y = __VERIFIER_nondet_int();w
    
    while (x > y) {
        x = x+1;
        y = y+2;
    }
    
    return 0;
}
