#include <stdio.h>

int main() {
    int x = 100;
    for (int i =0; i < 2; i++){
    	int x = x;
    	x = x + 5;
    	printf("x=%d\n",x);
    }
    printf("x = %d\n", x);
    return x;
}
