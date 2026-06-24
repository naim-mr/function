/* 
 * Terminating program which has a r.f. based on minimum
 *
 * Date: 15.12.2013
 * Author: Amir Ben-Amram, amirben@cs.mta.ac.il
 *
 */

typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x,y;
    int z;
   
    x = input("adv");
    y = input("env");
   
    while (y > 0 && x > 0) {
      if (x>y) {
          z = y;
      } else {
          z = x;
      }
      if (input("env") != 0) {
          y = y+x;
          x = z-1;
          z = y+z;
      } else {
          x = y+x;
          y = z-1;
          z = x+z;
      }
    }
    return 0;
}
