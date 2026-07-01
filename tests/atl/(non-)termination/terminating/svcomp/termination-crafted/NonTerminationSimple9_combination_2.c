/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
	int x;
    x = input("env");
	while (x >= 0) {
		x = x + input("adv");
	}
	return 0;
}
