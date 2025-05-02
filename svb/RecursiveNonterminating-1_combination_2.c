/*
 * Author: Matthias Heizmann
 * Date: 2014-06-29
 * 
 */

extern int __VERIFIER_nondet_int(void);


int rec(int x, int y) {
	if (x <= 23 && x >= -42) {
		rec(2*y-2, x + 1);
	}
    return 0;
}

int main() {
    int n = rand;                   
    if(!(n<=2147483646)) return 0;
    int ret = rec(n, n + 1);
    return 0;
}
