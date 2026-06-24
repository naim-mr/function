// -ctl_str "AU{x >= y}{x == y}"
// -domain polyhedra
// -precondition "x == y + 20"
int main() {
    // assume x > y
    int x = rand ();
    int y = rand ();
    while (x > y) {
        x = x - 1;
    }
    // now x == y
}
