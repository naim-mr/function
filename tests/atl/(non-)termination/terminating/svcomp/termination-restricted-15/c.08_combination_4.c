typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, i, j;
    i = input("adv");
    j = input("adv");
    c = 0;
    while (i >= 0) {
        j = 0;
        while (j <= i - 1) {
            j = j + 1;
        }
        i = i - 1;
    }
    return 0;
}
