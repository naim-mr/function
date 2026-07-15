/*
 * Date: 06/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

typedef enum {false, true} bool;


int main()
{
    int x;
    int y;
    x = input("adv")                ;
    y = input("adv")                ;
	if (y <= x) {
	    while (x >= 0) {
	    	x = x - y;
    	}
	}
	return 0;
}
