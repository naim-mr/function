/*
TERMINATION

suggested parameters:
- partition abstract domain = boxes [default]
- function abstract domain = ordinals 2
- backward widening delay = 3
*/

int main() {
  int x1, x2;
  while (x1 != 0 && x2 > 0)
    if (x1 > 0) {
      if (input("adv")) {
        x1 = x1 - 1;
        x2 = input("env");
      } else
        x2 = x2 - 1;
    } else {
      if (input("env"))
        x1 = x1 + 1;
      else {
        x2 = x2 - 1;
        x1 = input("env");
      }
    }
  return 0;
}