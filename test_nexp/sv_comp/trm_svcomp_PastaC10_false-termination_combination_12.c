typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int r;
    i = rand()                 ;
    j = input()                ;
    
    while (i - j >= 1) {
        i = i -  rand()                 ;
        r = rand()                  + 1;
        j = j + r;
    }
    
    return 0;
}
