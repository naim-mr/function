//-ctl "NOT{AF{ap > 2}}" -precondition "ap==0"
//#Safe
//
//@ ltl invariant positive: !<>AP(ap > 2);



int main() {
  int loop_counter;
  int ap;
  // ap = 0;

  // loop_counter = 1;

  while(loop_counter > 0) {
	  loop_counter--;
	  ap++; // ap == loop_counter
  }
}

