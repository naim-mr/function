typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y, z;
    x = input("env");
    y = input("env");
    z = input("env");
    c = 0;
    while (x > z) {
        while (y > z) {
            y = y - 1;
        }
        x = x - 1;
    }
    return 0;
}
