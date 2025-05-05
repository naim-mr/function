/* pulse-inf: works! no bug */
void loop_with_return_terminate_var1(int y) {
  while (y < 100)
    if (y == 50)
      return;
    else
      y++;
}



void main(){
    int y = input;                  
    loop_with_return_terminate_var1(y);
}