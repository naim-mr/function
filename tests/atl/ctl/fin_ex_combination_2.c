// FuncTion arguments:
// -ctl_cfg "EG{EF{n==1}}
// -precondition n > 0
// -domain polyhedra

void main() {
    int n = input("env");  //assume n > 0
    if (n < 0) return;
    while (n > 0) {
         n = n-1;
    }

   if (input("adv")){
        while (n == 0) {
            n = n + 1;
            n = n - 1;
        }
    }
}
