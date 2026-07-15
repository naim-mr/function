
/* pulse-inf: works good! no bug */
void loop_with_break_terminate(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      return;
    else
      y++;
}


void main(){
    int y = input("adv");                  
    loop_with_break_terminate(y);
}