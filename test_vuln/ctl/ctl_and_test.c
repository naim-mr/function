// FuncTion arguments:
// -ctl_cfg "AND{AG{AF{n==1}}}{AF{n==0}}"
// -precondition n > 0

void main() {
    int n;  //assume n > 0

    while (n > 0) {
        n--;
    }

    while (true) {
        n++;
        n--;
    }
}
