// *************************************************************
//
//     Branching-time reasoning for infinite-state systems
//
//              Byron Cook * Eric Koskinen
//                     July 2010
//
// *************************************************************

// -ctl_cfg "AF{resp > 5}"
// -precondition "c > 5"




void main() {
  int c; // assume c > 0
  int servers;
  int resp;
  int curr_serv = servers;
  while(curr_serv > 0) {
    if(?) {
      c--; curr_serv--;
      resp++;
    } else if (c < curr_serv) {
      curr_serv--;
    }
  }
  while(1) { int ddd; ddd=ddd; }
}

