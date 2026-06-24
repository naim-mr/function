typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int a;
    int b;
    int c;
    int r;
    a = input("adv")                ;
    b = input("env")                 ;
    c = input("adv")                ;
    
    while ( (b - c >= 1) && (a == c)) {
        r = input("env");
        b = 10;
        c = c + 1 + r;
        a = c;
    }
    
    return 0;
}
