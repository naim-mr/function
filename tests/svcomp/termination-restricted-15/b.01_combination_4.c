typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c;
    int x, y;
    x = input("adv");
    y = input("adv");
    c = 0;
    while (x > y) {
        x = x - 1;
    }
    return 0;
}
