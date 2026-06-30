typedef enum {false,true} bool;


int main() {
    int i;
    int range;
    i = input("adv")                ;
    range = 20;
    
    while (-range <= i && i <= range) {
        if (range-i < 5 || range+i < 5) {
            i = i*(-1);
        } else {
            range = range+1;
            i = i-1;
            if (i == 0) {
                range = -1;
            }
        }
    }
    
    return 0;
}
