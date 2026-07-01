typedef enum {false,true} bool;


int main() {
    
    int a;
    int b;
    int r;
    a = input("env")                 ;
    b = input("env")                 ;
    
    while (b > 0) {
        r =  input("env");
        b = a - 1 - r;
        a = a - 1 - r;
    }
    
    return 0;
}