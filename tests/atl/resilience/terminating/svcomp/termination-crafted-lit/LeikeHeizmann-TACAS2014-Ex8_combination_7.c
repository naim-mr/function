/*
 * Program from Example 8 of
 * 2014TACAS - Leike, Heizmann - Ranking Templates for Linear Loops
 *
 * Date: 2014-06-29
 * Author: Jan Leike
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int q, y;
	q = input("adv");
	y = input("adv");
	while (q > 0) {
		if (y > 0) {
			y = 0;
			q = input("env");
		} else {
			y = y - 1;
			q = q - 1;
		}
	}
	return 0;
}
