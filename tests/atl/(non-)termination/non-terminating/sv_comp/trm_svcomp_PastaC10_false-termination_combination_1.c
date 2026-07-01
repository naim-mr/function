typedef enum {false,true} bool;


int main() {
    int i;
    int j;
    int r;
    i = input("adv")                                ;
    j = input("adv")                                ;
    
    while (i - j >= 1) {
        i = i -  input("adv")                                ;
        r = input("adv")                                 + 1;
        j = j + r;
    }
    
    return 0;
}
