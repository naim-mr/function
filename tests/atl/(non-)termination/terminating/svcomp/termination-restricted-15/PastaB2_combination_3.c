typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    x = input("adv");
    y = input("env");
    
    while (x > y) {
        x = x-1;
        y = y+1;
    }
    
    return 0;
}
