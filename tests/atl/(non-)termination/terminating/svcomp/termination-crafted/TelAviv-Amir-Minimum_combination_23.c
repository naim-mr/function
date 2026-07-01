/*
 * Terminating program that has no linear lexicographic ranking function.
 * The program chooses nondeterministically the variable x or y and assigns to
 * it the result of   minimum(x,y)-1
 * The term   minimum(x,y)  is a ranking function for this program.
 *
 * Amir Ben-Amram (TelAviv) showed me this program when we met in Perpignan at
 * SAS 2010.
 *
 * Date: 1.12.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
	int x;
	int y;
	x = input("adv");
	y = input("env");
    while (x > 0 && y > 0) {
    	if (input("adv") != 0) {
    		if (x<y) {
    			y = x - 1;
    		} else {
    			y = y - 1;
    		}
    		x = input("adv");
    	} else {
    		if (x<y) {
    			x = x - 1;
    		} else {
    			x = y - 1;
    		}
    		y = input("env");
    	}
    }
    return 0;
}
