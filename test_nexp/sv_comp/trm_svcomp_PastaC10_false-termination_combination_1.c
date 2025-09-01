typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int r;
    i = input()                ;
    j = input()                ;
    
    while (i - j >= 1) {
        i = i -  input()                ;
        r = input()                 + 1;
        j = j + r;
    }
    
    return 0;
}
