/*
TERMINATION

suggested parameters:
- conflict-driven conditional termination
- partition abstract domain = boxes [default]
- function abstract domain = affine [default]
- backward widening delay = 2 [default]
*/


int main()  {
  int y, step;
  step = 1;
  if (y > 0) {
    step = -step;
  }
  while(y < -1 || y > 1) {
    y = y + step;
  }
  exit:
  return 0;
}