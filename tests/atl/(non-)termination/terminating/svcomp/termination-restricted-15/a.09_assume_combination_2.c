typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, z;
    x = input("env");
    y = input("env");
    z = input("adv");
    while (y > 0 && x >= z && z <= 2147483647 - y) {
        z = z + y;
    }
    return 0;
}
