typedef enum {false, true} bool;


int main()
{
    int x;
    int y;
    x = input("env")                 ;
    y = input("env")                 ;
    while (x > 0) {
        x = x + y;
        y = y + 1;
    }
    return 0;
}
