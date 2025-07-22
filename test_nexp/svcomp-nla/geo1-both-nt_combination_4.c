// This file is part of the SV-Benchmarks collection of verification tasks:
// https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks
//
// SPDX-FileCopyrightText: 2021 DynamiTe team <https://github.com/letonchanh/dynamite>
//
// SPDX-License-Identifier: Apache-2.0

/*
  A nonlinear termination benchmark program from the OOPSLA'20 paper 
  "DynamiTe: Dynamic termination and non-termination proofs"
  by Ton Chanh Le, Timos Antonopoulos, Parisa Fathololumi, Eric Koskinen, ThanhVu Nguyen.
  Adapted from the original nonlinear benchmark nla-digbench. 
*/

/* 
Geometric Series
computes x=(z-1)* sum(z^k)[k=0..k-1] , y = z^k
returns 1+x-y == 0
*/
extern int __VERIFIER_nondet_int(void);

int main() {
    int z, k;
    int x, y, c;
    z = rand()                   ;
    k = rand()                   ;

    x = 1; 
    y = z;
    c = 1;

    // r0: z  - 1 - z + 1 == 0 
    // r1: z^2 + z - z - 1 - z^2 + 1 == 0 
    while (1) {
        //__VERIFIER_assert(x*z - x - y + 1 == 0);
        // r1: z  - 1 - z + 1 == 0 
        if (!(x*z - x - y + 1 == 0)) 
            break;

        c = c + 1; // c =  
        x = x * z + 1; // x = z + 1 
        y = y * z; // z² 

    }  //geo1

    x = x * (z - 1);

    //__VERIFIER_assert(1 + x - y == 0);
    return 0;
}
