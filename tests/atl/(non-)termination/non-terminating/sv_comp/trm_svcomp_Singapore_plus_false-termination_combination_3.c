/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

typedef enum {false, true} bool;


int main()
{
    int x;
    int y;
    x = input("env")                                 ;
    y = input("adv")                                ;
    if (x + y >= 0) { 
        while (x > 0) {
            x = x + x + y;
            y = y + 1;
        }
    }
    return 0;
}
