typedef enum {false,true} bool;


int main() {
    int i;
    int j;
    int r;
    i = input("env")                                 ;
    j = input("env")                                 ;
    
    while (i - j >= 1) {
        i = i -  input("env")                                 ;
        r = input("adv")                                 + 1;
        j = j + r;
    }
    
    return 0;
}
