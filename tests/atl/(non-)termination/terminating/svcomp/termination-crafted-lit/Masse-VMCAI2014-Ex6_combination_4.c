/*
 * Program from Ex6 of
 * 2014VMCAI - Massé - Policy Iteration-Based Conditional Termination and Ranking Functions
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
	while (x >= 0) {
		x = x + y;
		if (y >= 0) {
			y = y - 1;
		}
	}
	return 0;
}
