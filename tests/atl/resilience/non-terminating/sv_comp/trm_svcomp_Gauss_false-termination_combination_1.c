typedef enum {false,true} bool;


int main() {
    int n;
    int sum;
    n = input("adv")                ;
    sum = 0;
    
    while (n != 0) {
        sum = sum + n;
        n = n - 1;
    }

    return 0;
}
