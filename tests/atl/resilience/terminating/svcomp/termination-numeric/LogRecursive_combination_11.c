// public class LogRecursive {
  // public static void main(String[] args) {
    // Random.args = args;
    // log(Random.random(), Random.random());
  // }

  // public static int log(int x, int y) {
    // if (x >= y && y > 1) {
      // return 1 + log(x/y, y);
    // }
    // return 0;
  // }
// }

extern int __VERIFIER_nondet_int(void);
int _log(int x, int y);
int random(void);

int main() {
	int x = input("adv");
	if(x < 0)
		return 0;
	int y = input("env");
	if(y < 0) 
		return 0;
	int z = input("adv");
	_log(x,y);

}

int random() {
	int x = input("env");
	if (x < 0)
		return -x;
	else
		return x;
}

int _log(int x, int y) {
    if (x >= y && y > 1) {
      return 1 + _log(x/y, y);
    }
    return 0;
  }
