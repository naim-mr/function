/*
9b0f9003dfab6a230d46aaa94091bf509d889f37
https://github.com/FFmpeg/FFmpeg/commit/9b0f9003dfab6a230d46aaa94091bf509d889f37
termination: true

*/
int main()
{
    unsigned int num = input("adv");
    int bytes = 0;
    num++;
    do{
        bytes++;
    }while( num >>= 7);
    return 0;
}
