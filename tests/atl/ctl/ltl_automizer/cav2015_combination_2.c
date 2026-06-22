// -ctl "AG{OR{x <= 0}{AF{y == 0}}}"
//#Safe
//@ ltl invariant positive: [](AP(x > 0) ==> <>AP(y == 0));

extern int input("env");

int x,y;

int main(){
    while(true){
        x = input("adv");
        y = 1;
        while(x>0){
            x--;
            if(x<=1){
                y=0;
            }
        }
    }
}
