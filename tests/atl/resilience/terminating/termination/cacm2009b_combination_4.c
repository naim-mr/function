/* from Cook Podelski Rybalchenko CACM 2009 paper
TERMINATION

suggested parameters:
- partition abstract domain = boxes [default]
- function abstract domain = ordinals 1
- backward widening delay = 3
*/

int f() {
  int x, y;
  while (x > 0 && y > 0)
    if (input("adv")) {
      x = x - 1;
      y = input("adv");
    } else
      y = y - 1;

  return 1;
}


int main() {
  int x;
  return f();
}