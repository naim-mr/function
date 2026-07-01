typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int z;
    x = input("adv");
    y = input("adv");
    z = input("env");
    
    while (x < y) {
        if (x < z) {
            x = x+1;
        } else {
            z = z+1;
        }
    }
    
    return 0;
}
