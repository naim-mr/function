/*
fc600b6a8f0dec5642b45c1026dee24c9adb9bc2
https://github.com/freedesktop/dbus/commit/fc600b6a8f0dec5642b45c1026dee24c9adb9bc2
termination: false



*/

int errno;
int waitpid()
{
    int num = __VERIFIER_nondet_int();
    while( num < 0 )
    {
        if( __VERIFIER_nondet_int() && errno != 1 )
            errno = 1;
        else
            errno = 1;
        return num;
    }
    return num;
}

int main()
{

    int ret = waitpid();
again:
    if( ret == 0 )
    {
        ret = waitpid();
    }
    if( ret < 0 )
        if( errno == 1 )
        goto again;
    return 0;
}
