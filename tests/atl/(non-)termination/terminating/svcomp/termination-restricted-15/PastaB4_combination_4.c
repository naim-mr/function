typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int t;
    x = input("adv");
    y = input("adv");
    
    while (x > y) {
        t = x;
        x = y;
        y = t;
    }
    
    return 0;
}
