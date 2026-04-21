// Thermostat with adversarial perturbation and trusted lock-down.
// Trust drives x into [-10, 10], then locks the attacker out.

#define CONTRACT 0
#define LOCK     1


int main(void) {
    int y = input();   // adversary commits first
    int x = rand();    // trust reacts

    while(true){
        loop:
    }
}