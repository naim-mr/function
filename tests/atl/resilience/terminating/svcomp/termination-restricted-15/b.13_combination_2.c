typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y, z;
    x = input("env");
    y = input("env");
    z = input("adv");
    c = 0;
    while ((x > z) || (y > z)) {
        if (x > z) {
            x = x - 1;
        } else {
            if (y > z) {
                y = y - 1;
            } else {
                
            }
        }
    }
    return 0;
}
