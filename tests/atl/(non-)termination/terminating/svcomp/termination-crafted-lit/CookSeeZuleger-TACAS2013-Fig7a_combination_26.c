//#terminating
/*
 * Program from Fig.7a of
 * 2013TACAS - Cook,See,Zuleger - Ramsey vs. Lexicographic Termination Proving
 *
 * Date: 9.6.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, d;
	x = input("env");
	y = input("adv");
	d = input("adv");
    while (x>0 && y>0 && d>0) {
        if (input("env") != 0) {
            x = x - 1;
            d = input("env");
        } else {
            x = input("adv");
            y = y - 1;
            d = d - 1;
        }
    }
    return 0;
}
