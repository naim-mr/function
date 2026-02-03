void loop5(int* p, int* base, int size) {
    int count = 0;
    while (count < size * 2) {
        printf("%d ", *p);
        p++;
        if (p == base + size) p = base; // wrap-around
        count++;
    }
}
