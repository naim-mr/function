typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    
    int a;
    int b;
    int r;
    a = input("adv")                ;
    b = input("adv")                ;
    
    while (b > 0) {
        r =  input("env");
        b = a - 1 - r;
        a = a - 1 - r;
    }
    
    return 0;
}