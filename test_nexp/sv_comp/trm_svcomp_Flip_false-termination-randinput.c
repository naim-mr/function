typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int t;
    i = rand();
    j = input();
    t = 0;
    
    while (i != 0 && j != 0) {
        t = i;
        i = j;
        j = t;
    }
    
    return 0;
}
