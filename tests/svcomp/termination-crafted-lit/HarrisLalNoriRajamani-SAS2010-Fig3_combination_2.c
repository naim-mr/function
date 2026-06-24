/*
 * Program from Fig.3 of
 * 2010SAS - Harris, Lal, Nori, Rajamani - AlternationforTermination
 *
 * Date: 12.12.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

extern int __VERIFIER_nondet_int(void);

int x;

void foo(void) {
	x--;
}


int main() {
	x = input("env");

	while (x > 0) {
		if (input("adv")) {
			foo();
		} else {
			foo();
		}
	}
	return 0;
}
