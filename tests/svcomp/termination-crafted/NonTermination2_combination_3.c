/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
	int x, oldx;
    x = input("adv");
	while (x > 1 && x >= 2*oldx) {
		oldx = x;
		x = input("env");
	}
	return 0;
}
