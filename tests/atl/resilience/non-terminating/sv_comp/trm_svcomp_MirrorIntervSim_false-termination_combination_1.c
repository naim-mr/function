typedef enum {false,true} bool;


int main() {
    int i;
    i = input("adv")                ;
    
    while (i != 0) {
        if (-5 <= i && i <= 35) {
            if (i < 0) {
                i = -5;
            } else {
                if (i > 30) {
                    i = 35;
                } else {
                    i = i-1;
                }	
            }					
        } else {
            i = 0;
        }
    }
    
    return 0;
}
