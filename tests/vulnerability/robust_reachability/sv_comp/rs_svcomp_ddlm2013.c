// Source: Isil Dillig, Thomas Dillig, Boyang Li, Ken McMillan: "Inductive
// Invariant Generation via Abductive Inference", OOPSLA 2013.

#include "assert.h"

int main() {
    int i,j,a,b;
    int flag;
    // a = 0;
    // b = 0;
    // j = 1;
    if (flag) {
        i = 0;
    } else {
        i = 1;
    }

    while (__VERIFIER_nondet_int()) {
        a = a + 1;
        b = b  + (j - i);
        i = i + 2;
        if (i%2 == 0) {
            j = j + 2;
        } else {
            j = j + 1;
        }
    }
    if (flag) {
       // __VERIFIER_assert(a == b);
       assert1:
    }
    return 0;
}
