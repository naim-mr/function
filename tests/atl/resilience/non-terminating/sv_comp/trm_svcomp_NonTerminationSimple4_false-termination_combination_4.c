/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 *
 * Does not terminate for y >= 5.
 */

typedef enum {false, true} bool;


int main()
{
    int x, y;
	x = input("env")                 ;
    y = input("env")                 ;
	if (y >= 5) {
	    while (x >= 0) {
		    y = y - 1;
    	}
    }
	return 0;
}
