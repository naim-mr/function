typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, x, y;
    x = input("adv");
    y = input("adv");
    c = 0;
    if (y > 46340) return 0;
    while ((x > 1) && (x < y)) {
        x = x*x;
        c = c + 1;
    }
    return 0;
}
