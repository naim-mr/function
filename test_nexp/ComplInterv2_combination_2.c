typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i;
    i = rand;                   
    
    while (i != 0) {
        if (i > -5 && i < 5) {
            if (i < 0) {
                i = i+1;
            }
            if (i > 0) {
                i = i-1;
            }
        } 			
    }
	
    return 0;
}
