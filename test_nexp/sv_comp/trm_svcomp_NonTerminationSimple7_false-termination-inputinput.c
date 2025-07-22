/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int c, x;
	x = input();
	c = input();
	if (c == 0) {
	    while (x >= 0) {
		    x = x + c;
	    }
    }
	return 0;
}
