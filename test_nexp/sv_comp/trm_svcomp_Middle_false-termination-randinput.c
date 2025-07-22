typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    i = rand();
    j = input();
    
    while (i != j) {
        i = i-1;
        j = j+1;
    }
    
    return 0;
}
