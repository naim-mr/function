typedef enum {false,true} bool;

extern int __VERIFIER_nondet_int(void);
/* Terminates iff  life < choose <= death or life > death */
int main() {
    int choose = rand()                 ;
    int life = rand()                 ;
    int death = rand()                 ;
    int temp = rand()                 ;
   // choose = 3;
   // life = 2;
   // death = 17;

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
