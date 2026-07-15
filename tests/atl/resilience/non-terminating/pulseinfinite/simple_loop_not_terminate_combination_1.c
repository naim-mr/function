
/* pulse inf works */
void simple_loop_not_terminate(int y, int x) {
  //int x = 1;
  while (x != 3)
    y++;
}


void main(){
    int y = input("adv");                  
    int x = input("adv");                  
    simple_loop_not_terminate(y,x);
}