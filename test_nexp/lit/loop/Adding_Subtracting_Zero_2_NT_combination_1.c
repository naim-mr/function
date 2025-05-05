/*
a6cba062051f345e8ebfdff34aba071ed73d923f
https://github.com/FFmpeg/FFmpeg/commit/a6cba062051f345e8ebfdff34aba071ed73d923f
termination: false


*/
int flag = 0;
int ff_subtitles_next_line()
{
    int i = input;                  
    i = i % 1000;
    int ret;
    if( flag == 1 )
        ret =  0;
    if( i == 0 )
    {
        flag = 1;
        ret =  0;
    }
    else if( i < 0 )
        ret = -i;
    else
        ret =  i;

    return ret;
}

int main()
{
    int b = input;                  
    int end = input;                  
    if( b < 0 || end < 0 )
        return 0;
    while( b < end )
    {
        b += ff_subtitles_next_line();
        if( b >= end - 4 )
        return 0;
    }
    return 0;
}
