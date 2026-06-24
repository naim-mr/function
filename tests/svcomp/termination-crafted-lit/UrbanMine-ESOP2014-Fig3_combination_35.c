/*
 * Program from Fig.3 of
 * 2014ESOP - Urban,Miné - An Abstract Domain to Infer Ordinal-Valued Ranking Functions
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
	int x;
	int y;
	x = input("adv");
	y = input("env");
	while (x != 0 && y > 0) {
	    if (x > 0) {
		    if (input("env") != 0) {
			    x = x - 1;
				y = input("env");
			} else {
			    y = y - 1;
			}
		} else {
		    if (input("adv") != 0) {
			    x = x + 1;
			} else {
			    y = y - 1;
				x = input("env");
			}		
		}
	}
    return 0;
}
