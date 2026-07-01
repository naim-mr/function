typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, tmp;
    x = input("env");
    tmp = input("adv");
    while ((x > 0) && (tmp < 1073741824) && (-1073741824 < tmp) && (x == 2*tmp)) {
        x = x - 1;
        tmp = input("env");
    }
    return 0;
}
