typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int z;
    x = input("adv");
    y = input("env");
    z = input("env");
    
    while (x > y && x > z) {
        y = y+1;
        z = z+1;
    }
    
    return 0;
}
