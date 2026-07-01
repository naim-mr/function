typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, x;
    x = input("adv");
    c = 0;
    while ((x > 1) && (x < 100)) {
        x = x*x;
        c = c + 1;
    }
    return 0;
}
