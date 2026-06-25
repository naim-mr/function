// -ctl "EF{r == 1}"
// -domain polyhedra
int main() {
    int x = input("adv");
    int y = input("env");
    int r = 0;
    while (input("adv")) { 
        x = x + 1;
        if (x == 200) {
            r = 1;
        }
    }
}

