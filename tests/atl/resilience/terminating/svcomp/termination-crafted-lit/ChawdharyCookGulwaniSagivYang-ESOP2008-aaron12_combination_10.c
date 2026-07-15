/*
 * Program used in the experimental evaluation of the following paper.
 * 2008ESOP - Chawdhary,Cook,Gulwani,Sagiv,Yang - Ranking Abstractions
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, z;
	x = input("adv");
	y = input("env");
	z = input("env");
	while (x >= y) {
		if (input("adv") != 0) {
			x = x + 1;
			y = y + x;
		} else {
			x = x - z;
			y = y + (z * z);
			z = z - 1;
		}
	}
	return 0;
}
