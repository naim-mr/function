/*
 * Date: 2012-02-12
 * Author: leike@informatik.uni-freiburg.de
 *
 * Ranking function: f(x, a, b) = x;
 * needs the loop invariant b >= a.
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x;
    int a;
    int b;
    x = input("adv");
    a = input("adv");
    b = input("adv");
    if (a == b) {
        while (x >= 0) {
            x = x + a - b - 1;
        }
    }
    return 0;
}
