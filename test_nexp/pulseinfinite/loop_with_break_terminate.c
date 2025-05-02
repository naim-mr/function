
/* pulse-inf: works good! no bug */
void loop_with_break_terminate(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      break;
    else
      y++;
}


void main(){
    int y = __VERIFIER_nondet_int();
    loop_with_break_terminate(y);
}