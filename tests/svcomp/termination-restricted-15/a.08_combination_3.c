typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("adv");
    y = input("env");
    c = 0;
    while (x > y && x < 2147483647) {
        x = x + 1;
        y = y + 2;
    }
    return 0;
}
