typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    x = input("env");
    y = input("adv");
    
    while (x == y && x > 0) {
        while (y > 0) {
            x = x-1;
            y = y-1;
        }
    }
    
    return 0;
}
