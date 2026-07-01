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
  if (y > 0) {
    if (y > 10) {
      step = -2;
    }else {
      step = -1;
    }    
  } else {
    if (y < -10) {
      step = 2;
    }else {
      step = 1;
    }
  }
  while(y < -2 || y > 2) {
    y = y + step;
  }
  exit:
  return 0;
}