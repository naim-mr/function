/* pulse-inf: works good */
extern void fcall(int y);

void loop_call_not_terminate(int y) {
  while (y == 100)
    fcall(y);
  return;
}

void main(){
    int y = __VERIFIER_nondet_int();
    loop_call_not_terminate(y);   
}