/*
TERMINATION

suggested parameters:
- partition abstract domain = boxes [default]
- function abstract domain = affine [default]
- backward widening delay = 2 [default]
*/
int f(int x);
int f(int x){
	if (x <= 0) {
		return 0;
	} else {
		f(x - 1);
	}}
int main(int x) {
	f(x);
	return 1;
}