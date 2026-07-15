typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, x, y;
    x = input("env");
    y = input("env");
    c = 0;
    while (x >= 0 && x < 2147483647) {
        x = x + 1;
        y = 1;
        while (x > y) {
            y = y + 1;
        }
        x = x - 2;
    }
    return 0;
}
