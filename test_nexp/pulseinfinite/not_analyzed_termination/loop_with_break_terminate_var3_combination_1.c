/* pulse-inf: works! no bug */
void loop_with_break_terminate_var3(int y) {
  while (y < 100)
    if (y == 50)
      break;
    else
      y++;
}

void main(){
    int y = input;                  
    loop_with_break_terminate_var3(y);
}