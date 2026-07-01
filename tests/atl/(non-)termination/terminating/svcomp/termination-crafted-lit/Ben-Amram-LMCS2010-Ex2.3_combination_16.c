/*
 * Program from Ex.2.3 of
 * 2010LMCS - Ben-Amram - Size-Change Termination, Monotonicity Constraints and Ranking Functions
 *
 * Date: 12.12.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, z;
	x = input("env");
	y = input("adv");
	z = input("adv");

	while (x > 0 && y > 0 && z > 0) {
		if (y > x) {
			y = z;
			x = input("adv");
			z = x - 1;
		} else {
			z = z - 1;
			x = input("adv");
			y = x - 1;
		}
	}
	return 0;
}
