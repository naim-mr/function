/* pulseinf: works good - no bug */
// Cook et al. 2006 proves termination with non determinism 
//#include <stdlib.h>
void	benchmark_simple_terminate_cook06()
{
  int x = __VERIFIER_nondet_int(), y = __VERIFIER_nondet_int(), z=__VERIFIER_nondet_int();
  if (y > 0) {
    do {
      if (__VERIFIER_nondet_int()) {
	x = x + y;
      }
      else
	{
	  z = x - y;
	}
    } while (x < y && y < z);
  }
}


void main(){
    benchmark_simple_terminate_cook06();
}