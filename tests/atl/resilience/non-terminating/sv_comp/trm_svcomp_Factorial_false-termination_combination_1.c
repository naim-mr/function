typedef enum {false,true} bool;


int main() {
    int j;
    int i;
    int fac;
    j = input("adv")                ;
    i = 1;
    fac = 1;
    
    while (fac != j) {
        fac = fac * i;
        i = i+1;
    }
	
    return 0;
}
