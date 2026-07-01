/*
 * Program used in the experimental evaluation of the following paper.
 * 2010SAS - Alias,Darte,Feautrier,Gonnord, Multi-dimensional Rankings, Program Termination, and Complexity Bounds of Flowchart Programs
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, n, b;
	n = input("adv");
	b = input("adv");
	x = input("env");
	y = input("env");
	while (x >= 0 && 0 <= y && y <= n) {
		if (b == 0) {
			y = y + 1;
			if (input("env") != 0) {
				b = 1;
            }
		} else {
			y = y - 1;
			if (input("env") != 0) {
				x = x - 1;
				b = 0;
			}
		}
	}
	return 0;
}
