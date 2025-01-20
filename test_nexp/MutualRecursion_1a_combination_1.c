/*
 * Date: 07/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

extern int input;                  

int f(int x);
int g(int x);

int f(int x) 
{ 
  if (x <= 0) return 0; 
  else return g(x) + g(x + 1); 
}

int g(int x) 
{ 
  if (x <= 0) return 0; 
  else return f(x - 1) + f(x - 2); 
}


int main() {
  int x = input;                  
  g(x);
}
