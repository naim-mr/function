/*
 * Date: 2014-03-24
 * Author: heizmann@informatik.uni-freiburg.de
 *
 * Simple program that has a 2-phase ranking function but no
 * 2-nested ranking function.
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int y, z;
	y = input("env");
	z = input("env");
	while (z >= 0) {
		y = y - 1;
		if (y >= 0) {
			z = input("env");
		} else {
			z = z - 1;
		}
	}
	return 0;
}
