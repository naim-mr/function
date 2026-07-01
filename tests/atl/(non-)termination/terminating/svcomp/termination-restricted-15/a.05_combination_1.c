typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("env");
    y = input("env");
    c = 0;
    while (y < 2147483647 && x >= y + 1) {
        y = y + 1;
    }
    return 0;
}
