/*
 * Program from Fig.4 of
 * 2011TACAS - Podelski,Rybalchenko - Transition Invariants and Transition Predicate Abstraction for Program Termination
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
	int x, y;
	x = input("adv");
	y = input("adv");
	while (x > 0 && y > 0) {
		if (input("env") != 0) {
			x = x - 1;
			y = input("env");
		} else {
			y = y - 1;
		}
	}
	return 0;
}
