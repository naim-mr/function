/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 * Adapted from the example Bangalore_true-termination.c
 */

typedef enum {false, true} bool;


int main()
{
    int x;
    int y;
    x = input("adv")                ;
    y = input("env")                 ;
	if (y < 1) {
	    while (x >= 0) {
	    	x = x - y;
    	}
	}
	return 0;
}
