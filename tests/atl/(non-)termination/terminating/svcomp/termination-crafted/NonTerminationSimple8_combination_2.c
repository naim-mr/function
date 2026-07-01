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
		if (input("env") != 0) {
			x = x + 1;
		} else {if (input("env") != 0) {
			x = x + 2;
		} else {if (input("env") != 0) {
			x = x + 3;
		} else {if (input("adv") != 0) {
			x = x + 4;
		} else {
			x = -1;
		}}}}
	}
	return 0;
}
