typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("adv");
    y = input("env");
    c = 0;
    if (y > 0) {
        while (x > 0) {
            if (x > y) {
                x = y;
            } else {
                x = x - 1;
            }
            c = c + 1;
        }
    }
    return 0;
}
