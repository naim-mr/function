// -ctl_str "EU{x >= y}{x == y}"
// -domain polyhedra
// -precondition "x > y"
int main() {
    // assume x > y
    int x = input("env");
    int y = input("env");
    if ( x <= y){
        return;
    }
   if (input("adv")){
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
