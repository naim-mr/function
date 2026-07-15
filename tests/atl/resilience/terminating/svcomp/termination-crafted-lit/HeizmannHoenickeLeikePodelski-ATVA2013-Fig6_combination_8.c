/*
 * Program from Figure 6 of
 * 2013ATVA - Heizmann, Hoenicke, Leike, Podelski - Linear Ranking for Linear Lasso Programs
 *
 * Date: 2014-06-29
 * Author: Jan Leike
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y;
	x = input("adv");
	y = input("adv");
	while (x >= 0 && y >= 1) {
		x = x - y;
		y = input("adv");
	}
	return 0;
}
