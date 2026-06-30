typedef enum {false,true} bool;


int main() {
    int i;
    int j;
    i = input("env")                 ;
    j = input("env")                 ;
    
    while (i != j) {
        i = i-1;
        j = j+1;
    }
    
    return 0;
}
