/*
 * Date: 08.10.2013
 * Author: leike@informatik.uni-freiburg.de
 *
 * An example tailored to the piecewise ranking template.
 *
 * A ranking function is
 *
 * f(p, q) = min(p, q).
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int p, q;
	q = input("env");
	p = input("adv");
	while (q > 0 && p > 0 && p != q) {
		if (q < p) {
			q = q - 1;
			p = input("adv");
		} else {if (p < q) {
			p = p - 1;
			q = input("env");
		}}
	}
	return 0;
}
