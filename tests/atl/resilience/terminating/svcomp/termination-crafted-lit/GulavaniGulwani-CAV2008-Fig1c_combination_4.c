/*
 * Program from Fig.1c of
 * 2008CAV - Gulavani,Gulwani - A Numerical Abstract Domain Based on Expression Abstraction and Max Operator with Application in Timing Analysis
 *
 * Date: 2014
 * Author: Caterina Urban
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main() {
    int x, i, n;
	x = input("env");
	i = input("adv");
	n = input("adv");
	while (x < n) {
		i = i + 1;
		x = x + 1;
	}
	return 0;
}
