typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y;
    x = input("env");
    y = input("env");
    if (x > 0) {
        while (x > y && y <= 2147483647 - x) {
            y = y + x;
        }
    }
    return 0;
}
