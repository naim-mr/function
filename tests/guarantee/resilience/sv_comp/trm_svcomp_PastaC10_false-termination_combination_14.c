typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    int j;
    int r;
    i = input("env")                                 ;
    j = input("env")                                 ;
    
    while (i - j >= 1) {
        i = i -  input("adv")                                ;
        r = input("env")                                  + 1;
        j = j + r;
    }
    
    return 0;
}
