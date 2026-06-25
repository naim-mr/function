// -ctl_str "AU{x >= y}{x == y}"
// -domain polyhedra
// -precondition "x >= y"
int main() {
    // assume x > y
    int x = input("adv");
    int y = input("env");
    while (x > y) {
        x = x - 1;
    }
    // now x == y
}
