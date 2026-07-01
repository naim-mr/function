typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y, z;
    x = input("adv");
    y = input("adv");
    z = input("adv");
    c = 0;
    while ((x > z) && (y > z)) {
        x = x - 1;
        y = y - 1;
    }
    return 0;
}
