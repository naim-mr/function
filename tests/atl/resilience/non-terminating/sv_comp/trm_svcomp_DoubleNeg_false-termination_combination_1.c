typedef enum {false,true} bool;


int main() {
    int i;
    int j;
    i = input("adv")                ;
    j = input("adv")                ;
    while (i*j > 0) {
        i = i - 1;
        j = j - 1;
    }
    
    return 0;
}
