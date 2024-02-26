//#Safe
//@ ltl invariant positive: [](AP(a == 1) ==> <>AP(r == 1) );



int main() {
    int a = 0;
    int n;
    int n_init;
    int m;
    int m_init;
    int r ;
    r = 0;

    m = m_init;
    while(m > 0) {
        a = 1;
        a = 0;
        n = n_init;
        while(n>0) {
            n--;
        }
        r = 1;
        r = 0;
    }
    while(1) { int x; x=x; }
}

