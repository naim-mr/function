typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int a;
    int b;
    int c;
    int r;
    a = input()                ;
    b = input()                ;
    c = input()                ;
    
    while ( (b - c >= 1) && (a == c)) {
        r = rand();
        b = 10;
        c = c + 1 + r;
        a = c;
    }
    
    return 0;
}
