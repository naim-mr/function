/*
 * Program used in the experimental evaluation of the following paper.
 * 2008ESOP - Chawdhary,Cook,Gulwani,Sagiv,Yang - Ranking Abstractions
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int i, j, an, bn;
	i = input("env");
	j = input("adv");
	an = input("adv");
	bn = input("env");
	while ((an >= i && bn >= j) || (an >= i && bn <= j) || (an <= i && bn >= j)) {
		if (an >= i && bn >= j) {
			if (input("adv") != 0) {
				j = j + 1;
			} else {
				i = i + 1;
			}
		} else {if (an >= i && bn <= j) {
			i = i + 1;
		} else {if (an <= i && bn >= j) {
			j = j + 1;
		}}}
	}
	return 0;
}
