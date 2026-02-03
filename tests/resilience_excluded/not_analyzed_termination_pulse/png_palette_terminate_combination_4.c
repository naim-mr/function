
/* From: libpng */
/* Test from libpng with typedefs */
void	png_palette_terminate(int p, int val)
{
  int	num;
  int	i;

  if (val == 0)
    num = 1;
  else
    num = 256;

  for (i = 0; i < num; i++)
    p = val;
  
}


void main(){
    int p = rand();                   
    int val = rand();                   
    png_palette_terminate(p,val);
}