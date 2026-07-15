/*
 * Date: 2014-06-10
 * Author: heizmann@informatik.uni-freiburg.de
 *
 * Since a[0] != a[k], k cannot be 0
 *
 */

extern int __VERIFIER_nondet_int(void);

int main() {
	int k = input("env");
	int a[1048];
 
  for (int i = 0; i < 1048; i++) {
    a[i] = input("adv");
  }

	if (k >= 0 && k < 1048) {
		if (a[0] == 23 && a[k] == 42) {
			int x = input("adv");
			while(x >=0) {
				x = x - k;
			}
		}
	}
	return 0;
}
