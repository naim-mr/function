/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 * Adapted from Copenhagen_true-termination.c
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x, y, oldx;
    x = input("adv");
    y = input("env");
	while (x >= 0 || y >= 0) {
		oldx = x;
		x = y - 1;
		y = oldx - 1;
	}
	return 0;
}
