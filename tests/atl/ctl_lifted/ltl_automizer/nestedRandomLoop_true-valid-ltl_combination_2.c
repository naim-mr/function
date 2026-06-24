// -ctl "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n"
// CHECK( init(main()), LTL( G("i >= n") ) )
extern int input("env") __attribute__ ((__noreturn__));



int main()
{	
	int n = input("adv");
	int i = 1;
	while(1){
		i++;
		while(i > n){
			n++;
		}
	}
		
}

