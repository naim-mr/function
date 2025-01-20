/*
 * Date: 2014-06-26
 * Author: leike@informatik.uni-freiburg.de
 *
 */

extern int input;                  

int main() {
	int i = input;                  
	int a[10];

	for (int n = 0; n < 10; ++n) {
		a[n] = input;                  
	}

	while (0 <= i && i < 10 && a[i] >= 0) {
		a[i] = 0;
		i = input;                  
	}
	return 0;
}
