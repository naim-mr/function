
int main()
{
	int ch4, count, enable;
	while (1) {
		ch4 = rand();
		if (ch4 <= 12000) {
			enable = 1;
			count = 15;
		} else if (ch4 > 12000 && ch4 < 60000) {
			if (count < 0) {
				enable = 0;
			} else {
				count--;
			}
		}
	}
}
