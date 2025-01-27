typedef enum {false, true} bool;

extern int __VERIFIER_nondet_int(void);

int main()
{
    int x;
    int y;
    x = rand;
    y = rand;
    while (x > 0) {
        x = x + y;
        y = y + 1;
    }
    return 0;
}
