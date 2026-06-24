/*
 * Program from Fig.1 of
 * 2010SAS - Harris, Lal, Nori, Rajamani - AlternationforTermination
 *
 * Date: 12.12.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

extern int __VERIFIER_nondet_int(void);


void f(int d) {
	int x = input("env");
	int y = input("env");
	int k = input("adv");
	int z = 1;
	if (k > 1073741823) {
		return;
	}
	// ...
	L1:
	while (z < k) {
		z = 2 * z;
	}
	L2:
	while (x > 0 && y > 0) {
		// ...
		if (input("adv")) {
			P1:
			x = x - d;
			y = input("adv");
			z = z - 1;
		} else {
			y = y - d;
		}
	}
}

int main() {
	if (input("env")) {
		f(1);
	} else {
		f(2);
	}
}
