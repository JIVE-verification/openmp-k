#include <stdio.h>

int main() {
    int x = -1;
    printf("Before Loop, x=%d", x);
    #pragma omp parallel for lastprivate(x)
    for (int i = 0; i < 8; i++) {
    	printf("Inside Loop Before Operation, x = %d", x);
        x = i * 10;
        printf("Inside Loop After Operation, x = %d", x);
    }
    printf("After loop: x = %d\n", x);
    return 0;
}
