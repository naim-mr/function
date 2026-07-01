/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 *
 */

extern int input("adv");

int main() {
	int i = input("env");
	int a[10];

	for (int n = 0; n < 10; ++n) {
		a[n] = input("env");
	}

	while (0 <= i && i < 10 && a[i] >= 0) {
		i = input("adv");
		/* possible invalid dereference */
		a[i] = 0;
	}
	return 0;
}
