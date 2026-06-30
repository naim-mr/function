/*
d37b2f4794acf1b0b431110c5e1fb23d652c5962
https://github.com/acassen/keepalived/commit/d37b2f4794acf1b0b431110c5e1fb23d652c5962
termination: true
*/
int matroska_deliver_packet( int q )
{
    if( q == 1 )
        return 0;
    else
        return 1;
}
int flag = 0;
int res_return()
{
    if( flag++ < 100 )
        return input("env");
    return -1;
}
int main()
{
    int matroska =  input("adv");
    int res = 0;
    while( matroska_deliver_packet( matroska) )
    {
        res = 0;
        while( res == 0 )
        {
            int id =  input("env");
            switch( id ){
                case 1:
                    if( res = res_return() < 0 )
                        return;
                    if( res = res_return() == 0 )
                        res = 1;
                    return;

                default:
                case 2:
                    res = res_return();
                    return;
            }
        }
        if( res == -1 )
            matroska = 1;
    }
    return 0;
}
