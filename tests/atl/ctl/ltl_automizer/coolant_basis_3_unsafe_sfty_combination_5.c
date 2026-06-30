
//#Unsafe
//@ ltl invariant positive: []( ! AP(init == 3) || []<>AP(time > otime));



int error, tempDisplay, warnLED, tempIn, chainBroken,
warnLight, temp, otime = 0, time = 0, limit, init;


void display(int tempdiff, int warning)
{
	tempDisplay = tempdiff;
	warnLED = warning;
}

int vinToCels(int kelvin)
{
	if (temp < 0) 
	{
		error = 1;
		display(kelvin - 273, error);
	}
	return;
}

void coolantControl()
{
	while(1)
	{
		otime = time;
	
		time = otime;	//BUG +1;
		tempIn = input("env");
		temp = vinToCels(tempIn);
		if(temp > limit) 
		{
			chainBroken = 1;
		}
	}
}

int main()
{
    init = 0;
    tempDisplay = 0;
    warnLED = 1;
    tempIn = 0;
    error = 0;
    chainBroken = 0;
    warnLight = 0;
    temp = 0;
    limit = 8;
    init = 1;
	
	while(1)
	{
		int limit = input("env");
		if(limit < 10 && limit > -273)
		{
			error = 0;
			display(0, error);
			return;
		} else {
			error = 1;
			display(0, error);
		}	
	}
	
	init = 3;
	coolantControl();	
}
