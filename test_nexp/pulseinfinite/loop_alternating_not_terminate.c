
/* pulse-inf: works good */
void loop_alternating_not_terminate(int y, int x) {
  int turn = 0;
  while (x < 100) {
    if (turn)
      x++;
    else 
      x--;
    if (turn){
        turn = 0;
    }else{
        turn = 1 ; 
    }
  }
}



void main(){
    int x = __VERIFIER_nondet_int();
    int y = __VERIFIER_nondet_int();
    loop_alternating_not_terminate(y,x);
}