
/* pulse-inf: works good */
void loop_conditional_not_terminate(int y) {
  int x = 0;
  //y = 0;
  while (y < 100){
    if (y < 50)
      x++;
    else
      y++;
  }
}

void main(){
    int y = input;                  
    loop_conditional_not_terminate(y);
}