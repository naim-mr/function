typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y;
    x = input("adv");
    y = input("env");
    while (x >= 0 && y > 0) {
        y = 1;
        while (x > y && y > 0 && y < 1073741824) {
            y = 2*y;
        }
        x = x - 1;
    }
    return 0;
}
