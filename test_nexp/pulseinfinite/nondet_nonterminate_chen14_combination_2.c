
/*** Chen et al. TACAS 2014 */
// TNT proves non-termination with non determinism
/* Pulse-inf: works good (also flag the bug) */
/* TO me: there is no bug here! problem in chen14 paper - the nondet() should eventually make it break */
//#include <stdlib.h>
//int	nondet() { return (rand()()); }
void nondet_nonterminate_chen14(int k, int i) {
  if (k >= 0)
    ;
  else
    i = -1;
  while (i >= 0)
    i = nondet();
  i = 2;
}




void main(){
    int k,i;
    k = input();                  
    i = rand();                   
    nondet_nonterminate_chen14(k,i);
}