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
    int i, j, k, an, bn, tk;
	i = input("env");
	j = input("adv");
	k = input("env");
	an = input("env");
	bn = input("env");
	tk = input("adv");
	while (((an >= i && bn >= j) || (an >= i && bn <= j) || (an <= i && bn >= j)) && k >= tk + 1) {
		if (an >= i && bn >= j) {
			if (input("env") != 0) {
				j = j + k;
				tk = k;
				k = input("env");
			} else {
				i = i + 1;
			}
		} else {if (an >= i && bn <= j) {
			i = i + 1;
		} else {if (an <= i && bn >= j) {
			j = j + k;
			tk = k;
			k = input("adv");
		}}}
	}
	return 0;
}
