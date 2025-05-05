
/* pulse-inf: works! no bug */
void loop_with_return_terminate(int y) {
  while (y < 100)
    if (y == 50)
      {
	y--;
	return;
      }
    else
      y++;
}

void main(){
    int y = rand;                   
    loop_with_return_terminate(y);
}