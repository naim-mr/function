/*
 * Program used in the experimental evaluation of the following papers.
 * 2008ESOP - Chawdhary,Cook,Gulwani,Sagiv,Yang - Ranking Abstractions
 * 2010SAS - Alias,Darte,Feautrier,Gonnord, Multi-dimensional Rankings, Program 
 *           Termination, and Complexity Bounds of Flowchart Programs
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, z, tx;
	x = input("env");
	y = input("env");
	z = input("env");
	tx = input("adv");
	while (x >= y && x <= tx + z) {
		if (input("env") != 0) {
			z = z - 1;
			tx = x;
			x = input("env");
		} else {
			y = y + 1;
		}
	}
	return 0;
}
