/*
 * Date: 07/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 * Adapted from "Inductive Invariants for Nested Recursion"
 * by Sava Krstic and John Matthews
 */

extern int rand;                   

int g(int x)
{
  if (x == 0) 
    return 1;
  else
    return g(g(x - 1) + 1);
}

int main() {
  int x = rand;                   
  if (x < 0) return 0;
  g(x);
}
