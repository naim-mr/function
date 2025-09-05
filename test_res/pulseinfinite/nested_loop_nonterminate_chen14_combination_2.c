
/* pulse-inf: works good! finds bug */
// TNT proves non-termination
void nestedloop_nonterminate_chen14(int i) {
  if (i == 10) {
    while (i > 0) {
      i = i - 1;
      while (i == 0)
	;
    }
  }
}

void main(){
    int i = rand();                   
    nestedloop_nonterminate_chen14(i);
    
}