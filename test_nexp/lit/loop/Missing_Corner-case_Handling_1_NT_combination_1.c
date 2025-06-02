/*
cd64eeac116d3bb4871d114b105440b4dd11b8e0
https://github.com/DPDK/dpdk/commit/cd64eeac116d3bb4871d114b105440b4dd11b8e0
termination: false

*/

int flag = 0;
int count = 0;
int read()
{
    int ret;
    if( flag == 1 || count > 100 ) //whether EOF or not
        ret = 0;
    int num =  input();                  
    if( num <= 0 ) //abnormal
    {
        ret =  -1;
    }
    else
    {
        num = num % 1000;
        if( num < 995 ) //read a char
        {
            count++;
            ret =  num;
        }
        else // EOF
        {
            flag = 1;
            ret =  0;
        }
    }
    return ret;

}
int main()
{
    while(1)
    {
        if( read() < 0 )
            break;
    }
    return 0;
}
