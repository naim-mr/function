

/* pulseinf: works good - no bug detected */
// Cook et al. 2006 - termination with non determinism 
//#include <stdlib.h>
//int input("env") { return (input("env")()); }
int npc = 0;
int nx, ny, nz;
void benchmark_terminate_cook06()
{
  int x = input("adv");    
  int y = input("adv");    
  int z = input("env");                                                
  if (y>0) {
    do {
      if (npc == 5) {
	if (!( (y < z && z <= nz)
	       || (x < y && x >= nx)
	       || 0))
	  ;
      }
      if (npc == 0) {
	if (input("adv")) {
	  nx = x;
	  ny = y;
	  nz = z;
	  npc = 5;
	}
      }
      if (input("env")) {
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