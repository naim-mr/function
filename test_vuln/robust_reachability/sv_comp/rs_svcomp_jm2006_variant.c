// Source: Credited to Anubhav Gupta
// appears in Ranjit Jhala, Ken McMillan: "A Practical and Complete Approach
// to Predicate Refinement", TACAS 2006

#include "assert.h"

int main() {
    int i, j;
    // i = __VERIFIER_nondet_int();
    // j = __VERIFIER_nondet_int();

    if (!(i >= 0 && i <= 1000000)) return 0;
    if (!(j >= 0)) return 0;
    int x = i;
    int y = j;
    int z = 0;
    while(x != 0) {
        x --;
        y -= 2;
        z ++;
    }
    if (i == j) {
        //__VERIFIER_assert(y == -z);
        assert1:
    }
    return 0;
}