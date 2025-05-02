/* Cook et al. 2006 - Prove termination with non-determinism involved */
int Ack(int x, int y)
{
  if (x>0) {
    int n;
    if (y>0) {
      y--;
      n = Ack(x,y);
    } else {
      n = 1;
    }
    x--;
    return Ack(x,n);
  } else {
    return y+1;
  }
}



void main(){
    int x = __VERIFIER_nondet_int();
    int y = __VERIFIER_nondet_int();
    int ret = Ack(x,y);
}