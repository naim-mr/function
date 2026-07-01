typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    x = input("adv");
    y = input("adv");
    
    while (x > 0) {
        while (y > 0) {
            y = y-1;
        }
        x = x-1;
    }
    
    return 0;
}
