typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x;
    int y;
    int z;
    x = input("env");
    y = input("env");
    z = input("env");
    
    while (x > z && y > z) {
        x = x-1;
        y = y-1;
    }
    
    return 0;
}
