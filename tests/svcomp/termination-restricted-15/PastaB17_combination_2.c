typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int z;
    x = input("env");
    y = input("env");
    z = input("adv");
    
    while (x > z) {
        while (y > z) {
            y = y-1;
        }
        x = x-1;
    }
    
    return 0;
}
