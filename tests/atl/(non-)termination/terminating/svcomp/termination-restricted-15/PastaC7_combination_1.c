typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int k;
    int t;
    i = input("env");
    j = input("env");
    k = input("env");
    
    while (i <= 100 && j < k) {
        i = j;
        j = i + 1;
        k = k - 1;
    }
    
    return 0;
}
