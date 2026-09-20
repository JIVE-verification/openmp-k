#include <stdio.h>

int main() {
    int x = 100;
    for (int i =0; i < 2; i++){
    	int y = x;
    	int x = x;
    	x = x + 5;
    	printf("x=%d, y=%d\n",x, y);
    }
    printf("x = %d\n", x);
    return x;
}
