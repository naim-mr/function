typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y;
    x = input("adv");
    y = input("env");
    while (x > 0 && x > y && y <= 2147483647 - x) {
       y = y + x;
    }
    return 0;
}
