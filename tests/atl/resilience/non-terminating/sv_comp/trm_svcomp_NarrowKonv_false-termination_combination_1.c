typedef enum {false,true} bool;


int main() {
    int i;
    int range;
    i = input("adv")                ;
    range = 20;
    
    while (0 <= i && i <= range) {
        if (!(0 == i && i == range)) {
            if (i == range) {
                i = 0;
                range = range-1;
            } else {
                i = i+1;
            }
        }
    }
    
    return 0;
}
