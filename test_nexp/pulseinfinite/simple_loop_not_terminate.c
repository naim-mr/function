
/* pulse inf works */
void simple_loop_not_terminate(int y, int x) {
  //int x = 1;
  while (x != 3)
    y++;
}


void main(){
    int y = __VERIFIER_nondet_int();
    int x = __VERIFIER_nondet_int();
    simple_goto_not_terminate(y,x);
}