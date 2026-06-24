typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y;
    x = input("env");
    y = input("adv");
    while ((x > 0) && (y > 0)) {
        if (x > y) {
            while (x > 0) {
                x = x - 1;
            }
        } else {
            while (y > 0) {
                y = y - 1;
            }
        }
    }
    return 0;
}
