
/* pulse-inf: works -- empty path condition, no bug */
void simple_loop_terminate() {
  int y = 0;
  while (y < 100)
    y++;
}

void main(){
    simple_loop_terminate();
}