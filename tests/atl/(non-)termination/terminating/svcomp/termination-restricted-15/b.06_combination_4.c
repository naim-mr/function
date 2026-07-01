typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("adv");
    y = input("adv");
    c = 0;
    while ((x > 0) && (y > 0)) {
        x = x - 1;
        y = y - 1;
        c = c + 1;
    }
    return 0;
}
