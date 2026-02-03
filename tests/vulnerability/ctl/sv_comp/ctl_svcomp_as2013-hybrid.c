// Source: Gianluca Amato, Francesca Scozzari: "Localizing Widening and Narrowing", SAS 2013.
// Example hybrid. https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks/-/blob/main/c/loop-lit/as2013-hybrid.c

#include <assert.h>
extern void abort(void);
//void reach_error() { assert(0); }
//void __VERIFIER_assert(int cond) { if(!(cond)) { ERROR: {reach_error();abort();} } }

int main() {
  
  int i,j;
  while (1) {
    i = i + 1;
    while (j < 10) {
    //    __VERIFIER_assert(0 <= i);
    //   __VERIFIER_assert(i <= 10);
      assert1:
      j++;
    }
    if (i > 9)
      i = 0;
  }
  return 0;
}
