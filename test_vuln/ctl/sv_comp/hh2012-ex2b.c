// Source: Nicolas Halbwachs, Julien Henry: "When the Decreasing Sequence Fails", SAS 2012.
// Example 2.b.

#include <assert.h>
// extern void abort(void);
// void reach_error() { assert(0); }
// void __VERIFIER_assert(int cond) { if(!(cond)) { ERROR: {reach_error();abort();} } }
// extern _Bool __VERIFIER_nondet_bool();

int main() {
  int n;
  while (1) {
    assert1:
    //__VERIFIER_assert(n <= 60);
    if (__VERIFIER_nondet_bool()) {
      if (n < 60) {
        n++;
      }
      else {
        assert2:
        //__VERIFIER_assert(n == 60);
        n = 0;
      }
    }
  }
  return 0;
}
