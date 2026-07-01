/* from Cook & Podelski & Rybalchenko CACM 2009 paper
TERMINATION

suggested parameters:
- partition abstract domain = boxes [default]
- function abstract domain = affine [default]
- backward widening delay = 2 [default]
*/


void main() {
  int x, y,b;
  while (x > 0 && y > 0)
    if (b) {
      x = x - 1;
      y = y + 1;
    } else
      y = y - 1;
}