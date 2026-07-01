typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, x, y, z;
    x = input("env");
    y = input("adv");
    z = input("adv");
    c = 0;
    while (x < y && z < 2147483647) {
        if (x < z) {
            x = x + 1;
        } else {
            z = z + 1;
        }
    }
    return 0;
}


