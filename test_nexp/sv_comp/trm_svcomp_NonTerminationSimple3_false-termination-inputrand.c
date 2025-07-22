/*
 * Date: 2013-12-16
 * Author: leike@informatik.uni-freiburg.de
 *
 * Does not terminate for c >= 0.
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
	int c, x;
    c = input();
	x = rand();
	while (x >= 0) {
		x = x + c;
	}
    return 0;
}

/*
if input()
	then 
		if rand() 
			while(true)
		else
			...	
else 
	if rand() 
		 ...
	else 
		...
 
 
 
 
*/