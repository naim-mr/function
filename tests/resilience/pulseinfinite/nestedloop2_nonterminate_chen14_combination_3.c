// TNT fails to prove non-termination
/* pulse-inf says there is no bug */
/* To me: this will terminate because k >= 0 will eventually be false due to integer wrap */
void nestedloop2_nonterminate_chen14(int k, int j) {
  while (k >= 0) {
    k++;
    j = k;
    while (j >= 1)
      j--;
  }
}


void main(){
    int k,j;
    k = rand();                   
    j = input();                  
    nestedloop2_nonterminate_chen14(k,j);
}