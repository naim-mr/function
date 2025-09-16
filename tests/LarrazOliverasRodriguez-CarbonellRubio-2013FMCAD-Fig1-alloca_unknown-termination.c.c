#include <stdlib.h>
#include <alloca.h>

int main() {
    int* x = alloca(sizeof(int));
    int* y = alloca(sizeof(int));
    int* z = alloca(sizeof(int));
    // continue only for values where there won't be any overflow or underflow
    // on systems where sizeof(int)=4 holds.
    if (*x > 10000 || *x < -10000 || *y > 10000 || *z > 10000) {
        return 0;
    }
    // x -> a_1, y -> a_2, z -> a_3 
    // -1000 < *a_1 < -1000 &&  *a_2 < 1000 && *a_3 < 1000
    while (*y >= 1) {
        // {x -> a_1,y -> a_2, z -> a_3} and val(a_1) >= 0 
        (*x)--; // {x -> a_1,y -> a_2, z -> a_3} and *a_2 >= 0 and *a_1 = top
        while (*y < *z) {
            /* :fun _ -> *a_2 + *a_1 >= 2  && *a_2 < *a_3 >= 2 */    
            (*x)++; 
            /* :fun _ -> *a_2 + *a_1 >= 2  && *a_2 < *a_3 >= 2 */    
            (*z)--;
            /* :fun _ -> *a_2 + *a_1 >= 2  && *a_2 < *a_3 >= 2 */    
             
        }
        // {x -> a_1,y -> a_2, z -> a_3} and *a_2 >= 0 and *a_1 = top
        /* :fun _ -> *a_2 + *a_1 >= 2  */    
        *y = *x + *y;  // {y -> a_1}
        // {x -> a_1,y -> a_2, z -> a_3} and *a_2 >= 0 and *a_1 = top
        /* :fun _ -> *a_2 >= 1  */    
    }   
    /* :fun _ -> 0  */
    return 0;
}
