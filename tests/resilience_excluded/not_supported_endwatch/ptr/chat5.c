#include <stdio.h>
#include <stdlib.h>


int main() {
    char tape[] = {4, 3, 2, 1, 0};
    int* p = &tape[1];
    while (*p) {
        if (*p % 2 == 0)
            p += *p;    // avance de *p octets
        else
            p -= *p;    // recule de *p octets
    }
    return 0;
}

