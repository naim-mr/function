// FuncTion arguments:
// -ctl_cfg "EG{EF{n==1}}
// -precondition n > 0
// -domain polyhedra

void main() {
    int n = input("adv");  //assume n > 0
    if (n < 0) return;
    while (n > 0) {
        n--;
    }

   if (input("env")){
        while (n == 0) {
            n++;
            n--;
        }
    }
}
