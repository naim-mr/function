// Source: E. De Angelis, F. Fioravanti, J. A. Navas, M. Proietti:
// "Verification of Programs by Combining Iterated Specialization with
// Interpolation", HCVS 2014 , https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks/-/blob/main/c/loop-lit/afnp2014.c
#include "assert.h"
int main() {
    int x,y;
    while (y < 1000 ) {
        x = x + y;
        y = y + 1;
    }
    //  __VERIFIER_assert(x >= y);
    here:
    return 0;
    
}
