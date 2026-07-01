/*
358a11a928cdca474c82472a2ca0d619426439f1
https://github.com/brltty/brltty/commit/358a11a928cdca474c82472a2ca0d619426439f1
termination: true


*/
int main()
{
    int i = 0;
    int base = input("adv");
    int count = input("env");
    int old_[10], new_[10];
    for( int j = 0 ; j < 9 ; j++ )
    {
        old_[j] = input("env");
        new_[j] = input("env");
    }
    old_[9] = 0;
    new_[9] = 0;
    while( base < count )
    {
        int number = base;
        while( old_[i] != new_[i] )
        {
            if( ++number == count )
                return;
        }
        i++;
        base += 8;
    }
    return 0;
}
