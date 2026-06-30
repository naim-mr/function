
/**
 * Samuel Ueltschi: example for potential termination
 *
 * -ctl_cfg "EF{exit: true}"
 */

int main() {
    int i;
    int x;
    int y;
    y = 1;
    i = input("adv");
    x = input("env");

    if (i > 10) {
        x = 1;
    }     
    while (x == y) { }
    
    return;
}
