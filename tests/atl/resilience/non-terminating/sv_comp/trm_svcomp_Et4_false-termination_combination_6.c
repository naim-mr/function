typedef enum {false,true} bool;


int main() {
    int a;
    int b;
    int c;
    int r;
    a = input("env")                 ;
    b = input("adv")                ;
    c = input("env")                 ;
    
    while ( (b - c >= 1) && (a == c)) {
        r = input("env");
        b = 10;
        c = c + 1 + r;
        a = c;
    }
    
    return 0;
}
