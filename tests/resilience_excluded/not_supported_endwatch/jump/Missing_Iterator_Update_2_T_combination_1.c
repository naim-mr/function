/*
8a7acbf81de51ff991bf8211eff248b46c2b5421
https://github.com/ximion/appstream/commit/8a7acbf81de51ff991bf8211eff248b46c2b5421
termination: true


*/
int flag = 0;
int mdb_cursor_get()
{
    int i =  input("env");;
    flag++;
    if( flag > 1000 )// avoid almost-sure
        return 1;
    if( i >= 0 )
        return 0;
    else
        return 1;
}

int main()
{
    int rc;
    rc = mdb_cursor_get();
    int dval_mv_size = input("env");
    while( rc == 0 )
    {
        if( dval_mv_size <= 0 )
        {
            rc = mdb_cursor_get();
            continue;
        }
        rc = mdb_cursor_get();
    }
    return 0;
}
