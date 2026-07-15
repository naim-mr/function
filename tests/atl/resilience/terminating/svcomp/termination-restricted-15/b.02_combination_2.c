typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("env");
    y = input("adv");
    c = 0;
    while (x > y) {
        x = x - 1;
        y = y + 1;
    }
    return 0;
}
