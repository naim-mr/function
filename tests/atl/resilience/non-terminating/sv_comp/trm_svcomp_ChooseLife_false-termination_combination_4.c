typedef enum {false,true} bool;

/* Terminates iff  life < choose <= death or life > death */
int main() {
    int choose = input("adv")                ;
    int life = input("adv")                ;
    int death = input("env")                 ;
    int temp = input("env")                 ;
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
