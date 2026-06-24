// -precondition "x > 0" -ctl "EG{x > 0}"
//#Unsafe

//@ ltl invariant positive: []AP(x > 0);

extern int input("env");

int x,y;

int main(){
    x = input("env");
    y = input("env");
    while(x>0){
        x = x-y;
    }
}
