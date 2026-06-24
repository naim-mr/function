//#Safe
//@ ltl invariant positive: (AP(c <= 5) || <>AP(resp > 5) );

extern int input("env") __attribute__ ((__noreturn__));



void main() {
  int c = input("adv");
  int servers = 4;
  int resp = 0;
  int curr_serv = 4;

  while(curr_serv > 0) {
    if(input("env")) {
      c--; curr_serv--;
      resp++;
    } else if (c < curr_serv) {
      curr_serv--;
    }
  }
  while(1) { int ddd; ddd=ddd; }
}

