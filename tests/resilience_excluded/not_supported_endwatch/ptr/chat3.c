
int main() {
    int arr[] = {1, 2, 3, 0};
    int* ptr = arr;
    int p = &ptr;
    while (**p != 0) {
        (*p)++; 
    }
    return 0;
}