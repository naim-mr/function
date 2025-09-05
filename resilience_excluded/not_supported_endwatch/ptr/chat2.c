
int main() {
    // si on a des exp linéaire sur les bases et offset la c'est bon
    int arr[] = {1, 2, 3, 4, 5};
    int* start = &arr[4]; 
    int* end = &arr[0];
    int x = [0,100];
    int* ptr = &x;
    // start -> alpha & alpha -> a_1#  end-> beta beta -> a2# & apha - beta >= beta, 
    // x -> [0,100]
    // Map1 : var -> addr U valeur
    // Map2 : addr -> valeur
    // Map3 : add -> addr_exp
    while (start > end)  start--; // start -> alpha end -> beta |  alpha -> a_1#  beta -> a2# 
                                  // alpha - 1   >= beta : 2 ? bot
    // fun _ -> 0 
    return 0;
}



int main() {
    // si on a des exp linéaire sur les bases et offset la c'est bon
    int arr[] = {4, 2, 3, 4, 5};
    start = &arr[4]; 
    end = &arr[0];
    while (*start >= *end)  start--;
    //  start -> alpha'  end -> beta  | alpha -> a_1# & alpha'-> a_3# & alpha''-> a_4# beta -> a2# 
    /*
       t_0:
       start = alpha => a1 >= a2 : bot ? 1 
       start = alpha + 1 =>   
            a3 >= a2 :
                a1 >= a2 : bot ? 3
                bot
        start = alpha + 2 =>
            a4 >= a2:
                a3 >= a2 :
                    a1 >= a2 : bot ? 5
                    bot
                bot
                

    
    */
    /* JOIN tree0 tree1 :
       start = alpha => a1 >= a2 : bot ? 1 
       start = alpha + 1 =>   
            a3 >= a2 :
                a1 >= a2 : bot ? 3
                bot

    */

    /*  tree1: start - 1 = alpha =>
                a3 >= a2:  
                     a1 >= a2 : bot ? 3
                     bot
    */
    /*   start - 1 = alpha => 
                a1 >= a2 : bot ? 2
                bot
    */
    
    
// tree0: start = alpha => a1 >= a2 : bot ? 1
    
    return 0;
}


