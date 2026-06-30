// -ctl_str "EU{x >= y}{x == y}"
// -domain polyhedra
// -precondition "x > y"
int main() {
    // assume x > y
    int x = input("adv");
    int y = input("env");
    if ( x <= y){
        return;
    }
   if (input("env")){
        // loop invariant: x >= y
        while (x > y) {
            x = x - 1;
        }
        // now x == y
        while(1){}
    } else {
        // on this trace be break the until property
        x = y - 1;
    }
}
