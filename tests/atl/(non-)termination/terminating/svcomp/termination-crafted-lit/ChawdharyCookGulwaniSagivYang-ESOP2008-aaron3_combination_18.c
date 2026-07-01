/*
 * Program used in the experimental evaluation of the following paper.
 * 2008ESOP - Chawdhary,Cook,Gulwani,Sagiv,Yang - Ranking Abstractions
 *
 * Date: 2014
 * Author: Caterina Urban
 */

extern int __VERIFIER_nondet_int(void);

int main() {
	int x = input("env");
	int y = input("adv");
	int z = input("env");
	int tx = input("env");
	while (x >= y && x <= tx + z) {
		if (input("env")) {
			z = z - 1;
			tx = x;
			x = input("adv");
		} else {
			y = y + 1;
		}
	}
	return 0;
}
