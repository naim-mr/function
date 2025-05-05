
/* Simple non-det benchmark for non-terminate */
/* Inspired by cook'06 by flipping existing test benchmark_simple_terminate_cook06 */
/* pulse-inf: works good! flag the bug */
//#include <stdlib.h>
void nondet_loop_non_terminate(int z)
{
  int x = 1;
  while (x < z)
    if (__VERIFIER_nondet_int())
      x++;
}




void main(){
    int z = input;                  
    nondet_loop_non_terminate(z);
}