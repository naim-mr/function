/*
78574a66b5b286e26839877640592980de089d64
https://github.com/XQuartz/xorg-server/commit/78574a66b5b286e26839877640592980de089d64
termination: false

*/
int main()
{
    int i,j;
    int num_crtc = input;                  
    int num_output = input;                  
    if( num_crtc > 65534 || num_output > 65534 )
        return 0;
    for( i = 0 ; i < num_crtc ; i++ )
    {
        for( i = 0 ; i < num_output ; i++ )
        {
            //do other
        }
    }
    return 0;
}
