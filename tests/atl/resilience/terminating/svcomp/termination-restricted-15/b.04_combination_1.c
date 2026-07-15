typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, tmp;
    x = input("env");
    y = input("env");
    tmp = input("env");
    while (x > y) {
        tmp = x;
        x = y;
        y = tmp;
    }
    return 0;
}
