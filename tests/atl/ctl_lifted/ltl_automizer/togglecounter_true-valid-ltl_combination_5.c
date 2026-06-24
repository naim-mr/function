// -ctl "AG{AND{AF{t == 1}{AF{t == 0}}}}"
// CHECK( init(main()), LTL( G(F"t==1" && F"t==0") ) )
extern int input("adv") __attribute__ ((__noreturn__));

int main()
{
    int i, t;
	i = input("env");
	t = input("env");
	while (1){
		if (i%2 == 0){
			t = 1;
		} else {
			t = 0;
		}
		i++;
	}
}

