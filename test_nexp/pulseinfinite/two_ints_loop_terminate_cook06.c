
/* pulse-inf: works good - no bug */
// Cook et al. 2006 - TERMINATOR proves termination
void two_ints_loop_terminate_cook06(int x, int y)
{
  if (y >= 1) 
    while (x >= 0)
      x = x + y;
}


void main(){
    int x = __VERIFIER_nondet_int();
    int y = __VERIFIER_nondet_int();
    two_ints_loop_terminate_cook06(x,y);
}