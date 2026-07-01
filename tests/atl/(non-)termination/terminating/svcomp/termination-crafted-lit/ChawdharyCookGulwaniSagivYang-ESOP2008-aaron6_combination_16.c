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
	x = input("env");
	tx = input("env");
	y = input("env");
	ty = input("env");
	n = input("env");
	if (x + y >= 0) {
		while (x <= n && x >= 2 * tx + y && y >= ty + 1 && x >= tx + 1) {
			if (input("adv") != 0) {
				tx = x;
				ty = y;
				x = input("adv");
				y = input("adv");
			} else {
				tx = x;
				x = input("adv");
			}
		}
	}	
	return 0;
}
