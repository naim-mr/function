typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);
int main() {
    int choose = rand();
    int life = input();
    int death = rand();
    int temp = input();
    while (life < death) {
        temp = death;
        death = life + 1;
        life = temp;
        
        if (choose < life || choose < death) {
            life = choose;
        }
    }
    
    return 0;
}
