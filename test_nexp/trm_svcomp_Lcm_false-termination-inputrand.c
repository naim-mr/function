typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int a = input; //0
    int b = rand;
    int am;
    int bm;
    am = a;
    bm = b;
    // bm != 0
    while (am != bm) {
        if (am > bm) {
            // bm < 0 
            bm = bm+b; // bm + b < bm < am
        } else {
            am = am+a;
        }
    }

    return 0;
}
