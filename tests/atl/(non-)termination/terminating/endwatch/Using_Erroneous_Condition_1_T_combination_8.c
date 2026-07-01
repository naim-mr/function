/*
0a8633d07e660813f630e4ab389bb4da9be8bb63
https://github.com/rkd77/elinks/commit/0a8633d07e660813f630e4ab389bb4da9be8bb63
termination: true

*/
typedef struct Node{
    int size;
    int selected;
}Node;



int main()
{
    Node* menu =(Node*)malloc(sizeof(Node));
    menu->selected = input("adv");
    menu->size = input("adv");
    if( menu->selected <= -2 || menu->size < 1 )
        return 0;
    int pos = menu->selected;
    int direction;
    int action_id =  input("adv");
    if( action_id > 0 && pos >= 1 )
    {
        pos--;
        direction = -1;
    }
    else
    {
        pos++;
        direction = 1;
    }
    pos %= menu->size;
    int start = pos;
    do{
        pos += direction;
        if( pos == menu->size ) pos = 0;
        else if( pos < 0 ) pos = menu -> size - 1;
    }while( pos != start );
    return 0;
}
