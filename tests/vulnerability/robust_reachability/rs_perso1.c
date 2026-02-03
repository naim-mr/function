//https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks/-/blob/main/c/loops/count_up_down-2.c
int main()
{
  int x = 100; 
  int y = 0 ;
  int safe = 0 ; 
  
  while(x>0)
  {  
    x = x - 1; 
    y = y + 1;
  }; 
  if(y == 100) {
    safe = 1 ;
  }
  return 0;
}


/*
// __VERIFIER_assert(y==n);
*/