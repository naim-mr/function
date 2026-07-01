/*
 * Date: 2013-12-16
 * Author: leike@informatik.uni-freiburg.de
 *
 * Rotates x and y by 90 degrees
 * Does not terminate.
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main ()
{
    int oldx;
	int x;
	int y;
	x = input("adv");
	y = input("env");
	while (true) {
        oldx = x;
		x = -y;
		y = oldx;
	}
	return 0;
}
