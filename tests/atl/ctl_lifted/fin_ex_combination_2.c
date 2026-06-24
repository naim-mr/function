// FuncTion arguments:
// -ctl_cfg "EG{EF{n==1}}
// -precondition n > 0
// -domain polyhedra

void main() {
    int n = rand ();  //assume n > 0

    while (n > 0) {
        n--;
    }

   if (input("adv")){
        while (n == 0) {
            n++;
            n--;
        }
    }
}
