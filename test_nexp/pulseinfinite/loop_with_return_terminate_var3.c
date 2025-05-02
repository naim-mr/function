

/* pulse-inf: works good! no bug */
void loop_with_return_terminate_var3(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      return;
    else
      y++;
}


void main(){
    int y = __VERIFIER_nondet_int();
    loop_with_return_terminate_var3(y);
}