// -ctl "AF{x > 10000}"
//#Safe
//@ ltl invariant positive: (<> AP(x > 10000));

void main()
{	

	int x;
    while(1){
		if(x<10){
			x++;
		} else {
			x = x*5;
		}
		x++;
    }
}

