/*
 * Date: 28.09.2015
 * Author: Thomas Ströder
 */
extern int __VERIFIER_nondet_int(void);
int main() {
  int x; 
  int y = x+3;
  while (x>0) {
    x = x-1;
    y = y-1;
  }
  return 0;
}

