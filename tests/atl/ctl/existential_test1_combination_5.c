// -ctl_str "EF{r == 1}"
// -precondition "2*x <= y+3"
int main() {
    int r = 0;
    int x = input("adv");
    int y = input("env");
    if (2*x <= y+3) {
        if (input("env") == 1) {
            r = 1;
        } 
    }
}

