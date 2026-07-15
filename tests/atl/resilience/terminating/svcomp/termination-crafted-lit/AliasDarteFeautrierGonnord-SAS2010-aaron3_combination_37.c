/*
 * Program used in the experimental evaluation of the following paper.
 * 2010SAS - Alias,Darte,Feautrier,Gonnord, Multi-dimensional Rankings, Program Termination, and Complexity Bounds of Flowchart Programs
 *
 * Date: 2014
 * Author: Caterina Urban
 */

extern int __VERIFIER_nondet_int(void);

int main() {
	int x = input("adv");
	int y = input("env");
	int z = input("env");
	int tx = input("adv");
	while (x >= y && x <= tx + z) {
		if (input("env")) {
			z = z - 1;
			tx = x;
			x = input("env");
		} else {
			y = y + 1;
		}
	}
	return 0;
}