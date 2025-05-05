
/* pulse-inf: works good! no bug */
void loop_with_break_terminate_var2(int y) {
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
    int y = input;                  
    loop_with_break_terminate_var2(y);
}