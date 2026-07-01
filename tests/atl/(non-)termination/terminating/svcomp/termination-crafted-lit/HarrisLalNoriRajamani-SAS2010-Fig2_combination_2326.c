/*
 * Program from Fig.2 of
 * 2010SAS - Harris, Lal, Nori, Rajamani - AlternationforTermination
 * for k = 4 and 8 paths through foo.
 *
 * Date: 12.12.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

extern int __VERIFIER_nondet_int(void);


/*
 * Procedure that has 8 path through its body.
 */
int foo(void) {
	int y = input("env");
	if (input("env")) {
		if (input("env")) {
			if (input("adv")) {
				y = 0;
			} else {
				y = 1;
			}
		} else {
			if (input("env")) {
				y = 2;
			} else {
				y = 3;
			}
		}
	} else {
		if (input("env")) {
			if (input("adv")) {
				y = 4;
			} else {
				y = 5;
			}
		} else {
			if (input("env")) {
				y = 6;
			} else {
				y = 7;
			}
		}
	}
	return y;
}


int main() {
	int d = 1;
	int x = input("env");

	if (input("env")) {
		d = d - 1;
	}


	if (input("adv")) {
		foo();
	}
	if (input("env")) {
		foo();
	}
	if (input("adv")) {
		foo();
	}
	if (input("env")) {
		foo();
	}

	// I think there is a typo in the paper and the following
	// decrement can be omitted.
	if (input("adv")) {
		d = d - 1;
	}

	while (x > 0) {
		x = x - d;
	}
	return 0;
}
