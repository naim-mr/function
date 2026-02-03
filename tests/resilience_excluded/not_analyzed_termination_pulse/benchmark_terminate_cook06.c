

/* pulseinf: works good - no bug detected */
// Cook et al. 2006 - termination with non determinism 
//#include <stdlib.h>
//int __VERIFIER_nondet_int() { return (rand()()); }
int npc = 0;
int nx, ny, nz;
void benchmark_terminate_cook06()
{
  int x = __VERIFIER_nondet_int();    
  int y = __VERIFIER_nondet_int();    
  int z = __VERIFIER_nondet_int();                                                
  if (y>0) {
    do {
      if (npc == 5) {
	if (!( (y < z && z <= nz)
	       || (x < y && x >= nx)
	       || 0))
	  ;
      }
      if (npc == 0) {
	if (__VERIFIER_nondet_int()) {
	  nx = x;
	  ny = y;
	  nz = z;
	  npc = 5;
	}
      }
      if (__VERIFIER_nondet_int()) {
	x = x + y;
      } else {
	z = x - y;
      }
    } while (x < y && y < z);
  }
}

void main(){
    benchmark_terminate_cook06();
}