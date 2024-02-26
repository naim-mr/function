// *************************************************************
//
//     Branching-time reasoning for infinite-state systems
//
//              Byron Cook * Eric Koskinen
//                     July 2010
//
// *************************************************************

// Benchmark: acqrel.c
// Property: AG(a => AF r)

// FuncTion arguments:
// -ctl_cfg "AG{OR{A!=1}{AF{R==1}}}" 
// -precondition "A==0 && R==0"



void main() {
  int n;
  int r ;
  int a ;
  while(?) {
    r = 1;
    a = 0;
    n = ?;
    while(n>0) {
      n--;
    }
    r = 1;
    r = 0;
  }
  while(1) { int x; x=x; }
}

