/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 * Adapted from the example Bangalore_true-termination.c
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x;
    int y;
    x = input();
    y = rand();
	if (y >= 0) {
	    while (x >= 0) {
	    	x = x - y;
    	}
	}
	return 0;
}

