

int main(void) {
    int q = 0;
    while (1) {
        if (q == 0) {                       // q0 : out_of_gate, train joue
            int a = input();
            if (a == 0)  q = 0;
            else q = 1;
        } else if (q == 1) {                // q1 : request, ctr joue
            int c = (rand());
            if      (c == 0) q = 0;         // refuser
            else if (c == 1) q = 1;         // attendre
            else             q = 2;         // accorder
        } else if (q == 2) {                // q2 : grant, train joue
            int a = input();
            if (a == 0)  q = 3;
            else q = 0;
             // entrer / libérer
        } else {                            // q3 : in_gate, ctr joue
            int c = rand();
            if (c == 0) {
                q = 0;
            } else if (c == 1) {
                q = 3;
            }
        }
    }
}

