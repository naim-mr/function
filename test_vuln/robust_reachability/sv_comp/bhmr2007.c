// Source: Dirk Beyer, Thomas A. Henzinger, Rupak Majumdar, Andrey
// Rybalchenko: "Path Invariants", PLDI 2007.

#include "assert.h"
int main() {

    int i, n, a, b;
    // i = 0;
    // a = 0; 
    // b = 0;
    //i = 0; a = 0; b = 0; n = __VERIFIER_nondet_int();
    if (!(n >= 0 && n <= 1000000)) return 0;
    while (i < n) {
        if (?) {
            a = a + 1;
            b = b + 2;
        } else {
            a = a + 2;
            b = b + 1;
        }
        i = i + 1;
    }
    assert1:
    //__VERIFIER_assert(a + b == 3*n);
    return 0;
}
