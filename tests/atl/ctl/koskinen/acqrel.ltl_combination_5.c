//#Safe
//@ ltl invariant positive: [](AP(a == 1) ==> <>AP(r == 1) );

extern int input("adv") __attribute__ ((__noreturn__));

int a = 0;
int r = 0;

void main() {
  int n;
  while(input("env")) {
    a = 1;
    a = 0;
    n = input("env");
    while(n>0) {
      n--;
    }
    r = 1;
    r = 0;
  }
  while(1) { int x; x=x; }
}

