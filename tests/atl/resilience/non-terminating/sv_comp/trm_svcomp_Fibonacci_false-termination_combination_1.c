typedef enum {false,true} bool;


int main() {
    int n;
    int i;
    int j;
    int t;
    n = input("adv")                ;
    i = 0;
    j = 1;
    t = 0;
    
    while (j != n) {
        t = j+i;
        i = j;
        j = t;
    }
	
    return 0;
}
