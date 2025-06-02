
/* From: AProVE: Non-termination proving for C Programs (Hensel et al. TACAS 2022)*/
/* pulse-inf: Works good! (flag bug) */
void hensel_tacas22_non_terminate(int x, int y)
{
  y = 0;
  while (x > 0)
    {
      x--;
      y++;
    }
  while (y > 1)
    y = y;
}


void main(){
    int x = input();                  
    int y = rand();                   
    hensel_tacas22_non_terminate(x,y);
}