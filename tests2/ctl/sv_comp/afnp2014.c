// Source: E. De Angelis, F. Fioravanti, J. A. Navas, M. Proietti:
// "Verification of Programs by Combining Iterated Specialization with
// Interpolation", HCVS 2014 , https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks/-/blob/main/c/loop-lit/afnp2014.c
#include "assert.h"
int main() {
    int x = 1;
    int y = 0;
    while (y < 1000 && ?) {
        x = x + y;
        y = y + 1;
    }
    here:
    return 0;
    
}
