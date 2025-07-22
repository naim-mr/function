/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x, y, z;
    x = rand();
    y = input();
    z = input();
    while (x > 0) {
        x = x + y;
        y = y + z;
        z = z + 1;
    }
    return 0;
}
