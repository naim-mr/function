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
    int x, tx, y, ty, n;
	x = input("adv");
	tx = input("env");
	y = input("adv");
	ty = input("env");
	n = input("adv");
	if (x + y >= 0) {
		while (x <= n && x >= 2 * tx + y && y >= ty + 1 && x >= tx + 1) {
			if (input("adv") != 0) {
				tx = x;
				ty = y;
				x = input("env");
				y = input("env");
			} else {
				tx = x;
				x = input("adv");
			}
		}
	}	
	return 0;
}
