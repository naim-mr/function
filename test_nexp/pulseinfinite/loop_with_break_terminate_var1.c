
/* pulse-inf: works good! no bug */
void loop_with_break_terminate_var1(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      {
	y--;
	break;
      }
    else
      y++;
}


void main(){
    int y = __VERIFIER_nondet_int();
    loop_with_break_terminate_var1(y);
}