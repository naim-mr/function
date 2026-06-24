/* pulseinf: works good - no bug */
// Cook et al. 2006 proves termination with non determinism 
//#include <stdlib.h>
void	benchmark_simple_terminate_cook06()
{
  int x = rand()                   ;                                                                          
  int y = input()                  ;
  int z = rand()                   ;                                                                          


  if (y > 0) {
    do {
      if (rand()                   ) {
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