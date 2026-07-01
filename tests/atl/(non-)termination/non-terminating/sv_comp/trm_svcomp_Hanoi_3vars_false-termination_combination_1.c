/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

typedef enum {false, true} bool;


int main()
{
    int x, y, z;
    x = input("adv")                ;
    y = input("env");
    z = input("env");
    while (x > 0) {
        x = x + y;
        y = y + z;
        z = z + 1;
    }
    return 0;
}
