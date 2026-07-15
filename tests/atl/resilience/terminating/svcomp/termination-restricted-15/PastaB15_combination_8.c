typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int z;
    x = input("adv");
    y = input("adv");
    z = input("adv");
    
    while (x == y && x > z) {
        while (y > z) {
            x = x-1;
            y = y-1;
        }
    }
    
    return 0;
}
