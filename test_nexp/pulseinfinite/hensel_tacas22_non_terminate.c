
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
    int x = __VERIFIER_nondet_int();
    int y = __VERIFIER_nondet_int();
    hensel_tacas22_non_terminate(x,y);
}