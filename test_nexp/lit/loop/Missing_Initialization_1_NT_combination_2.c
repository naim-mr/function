/*
407a3d94f566a68c7a862fcdac812bf53741af94
https://github.com/FFmpeg/FFmpeg/commit/407a3d94f566a68c7a862fcdac812bf53741af94
termination: false
*/
int main()
{
    int res = 0;
    int pkt = input();                  
    while( pkt < 10 )
    {
        while( res == 0 )
        {
            res = rand();                   
            pkt++;
        }
    }
    return 0;
}
