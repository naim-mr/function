//#terminating
/*
 * Program from Fig.7b of
 * 2013TACAS - Cook,See,Zuleger - Ramsey vs. Lexicographic Termination Proving
 *
 * Date: 9.6.2013
 * Author: heizmann@informatik.uni-freiburg.de
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, y, z;
	x = input("adv");
	y = input("adv");
	z = input("env");
	while (x>0 && y>0 && z>0) {
		if (input("adv") != 0) {
			x = x - 1;
		} else {if (input("env") != 0) {
			y = y - 1;
			z = input("adv");
		} else {
			z = z - 1;
			x = input("adv");
		}}
	}
    return 0;
}
