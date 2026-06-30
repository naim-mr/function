typedef enum {false,true} bool;


int main() {
    int i;
    int j;
    int t;
    i = input("adv")                ;
    j = input("adv")                ;
    t = 0;
    
    while (i != 0 && j != 0) {
        t = i;
        i = j;
        j = t;
    }
    
    return 0;
}
