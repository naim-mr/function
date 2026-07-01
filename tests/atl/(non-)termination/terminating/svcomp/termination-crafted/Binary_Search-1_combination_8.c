/*
 * Date: 07/07/2015
 * Created by: Ton Chanh Le (chanhle@comp.nus.edu.sg)
 */

extern int input("env");

int binary_search(int i, int j)
{
  if (i>=j) return i;
  int mid = (i+j)/2;
  if (input("adv")) 
    return binary_search(i,mid);
  return binary_search(mid+1,j);
}


int main() {
  int x = input("adv");
  int y = input("adv");
  binary_search(x, y);
}
