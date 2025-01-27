typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int a = rand; //0
    int b = input; //0
    int am;
    int bm;
    am = a;
    bm = b;
    // am != 0
    while (am != bm) {
        if (am > bm) { // am >0 
            bm = bm+b; // bm = 0 
        } else {
            //am < 0 
            am = am+a;  //am + a < am 
        }
    }

    return 0;
}
