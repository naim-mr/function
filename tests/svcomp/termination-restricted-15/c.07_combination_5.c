typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int c, i, j, k, tmp;
    i = input("env");
    j = input("adv");
    k = input("env");
    tmp = input("env");
    c = 0;
    while ((i <= 100) && (j <= k) && (k > -2147483648)) {
        tmp = i;
        i = j;
        j = tmp + 1;
        k = k - 1;
    }
    return 0;
}
