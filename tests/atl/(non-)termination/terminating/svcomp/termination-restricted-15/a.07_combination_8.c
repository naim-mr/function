typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y, z;
    x = input("adv");
    y = input("adv");
    z = input("adv");
    c = 0;
    while ((x > y) && (x > z)) {
        y = y + 1;
        z = z + 1;
    }
    return 0;
}
