#include <stdio.h>

int main() {
    int x = 100;
    for (int i = 0; i < 20; i++) {
    	int x=0;
        x += i;
        printf("%d\n",x);
    }
    printf("%d", x);
    return x;
}
