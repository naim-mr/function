/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 */

typedef enum {false, true} bool;


int main()
{
    int c, x;
	x = input("env")                 ;
	c = input("adv")                ;
	if (c == 0) {
	    while (x >= 0) {
		    x = x + c;
	    }
    }
	return 0;
}
