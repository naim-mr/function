// Source: Nicolas Halbwachs, Julien Henry: "When the Decreasing Sequence Fails", SAS 2012.
// Example 1.b.

#include <assert.h>
// extern void abort(void);
// void reach_error() { assert(0); }
// void __VERIFIER_assert(int cond) { if(!(cond)) { ERROR: {reach_error();abort();} } }

int main() {
  int i;
  int j;
  while (i < 100) {
    
    while (j < 100) {
      j++;
      assert1:
      //__VERIFIER_assert(j <= 100);
    }
    assert2:
    // __VERIFIER_assert(j == 100);
    i = i + 1;
    assert3:
    //__VERIFIER_assert(i <= 100);
  }
  assert4:
  //__VERIFIER_assert(i == 100);
  return 0;
}
