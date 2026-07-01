/*
 * Date: 2013-07-10
 * Author: heizmann@informatik.uni-freiburg.de
 *
 * Ranking function: f(x) = x
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main ()
{
    int x, b;
	x = input("adv");
	b = input("adv");
	while (b != 0) {
		b = input("adv");
		x = x - 1;
        if (x >= 0) {
            b = 1;
        } else {
            b = 0;
        }
	}
	return 0;
}
