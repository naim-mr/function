
/* Harris et al. "Alternation for Termination (SAS 2010) - Non Terminating program */
/* TERMINATOR unable to find bug */
/* TREX find bug in 5sec */
/* pulse-inf: works good! Detect the bug! */
void loop_non_terminating_harris10(int x, int d, int z)
{
  d = 0;
  z = 0;
  while (x > 0) {
    z++;
    x = x - d;
  }
}



void main(){
    int x,d,z;
    x = input;                  
    d = input;                  
    z = rand;                   
    loop_non_terminating_harris10(x,d,z);
}