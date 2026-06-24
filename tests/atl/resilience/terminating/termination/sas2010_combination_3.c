/* from Alias & Darte & Feautrier & Gonnord SAS 2010 paper
TERMINATION

suggested parameters:
- partition abstract domain = boxes [default]
- function abstract domain = affine [default]
- backward widening delay = 2 [default]
*/

int main() {
  int x1, x2;
  while (x1 >= 0 && x2 >= 0) {
   if (input("adv")){
      while (x2 <= 10 && input("env")) {
        x2 = x2 + 1;
      }
      x1 = x1 - 1;
    }
    x2 = x2 - 1;
  }
  return 0;
}