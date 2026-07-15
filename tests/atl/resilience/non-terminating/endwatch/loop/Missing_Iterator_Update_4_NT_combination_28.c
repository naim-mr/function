/*
78d9891dfebe63433b47076583df812992b3db7c
https://github.com/blender/blender/commit/78d9891dfebe63433b47076583df812992b3db7c
termination: false


*/
int main()
{
    int x = input("env");                   
    int mat_colSize = input("env");                   
    int y = input("adv");                  
    int z = input("env");                   
    int mat_rowSize = input("env");                   
    if( mat_colSize < 0 || mat_rowSize < 0 || mat_colSize > 65534 || mat_rowSize > 65534 )
        return 0;
    for( x = 0 ; x < mat_colSize ; z++ )
    {
        for( y = 0 ; y < mat_rowSize; y++ )
        {
            //loop
        }
        z++;
    }
    return 0;
}
