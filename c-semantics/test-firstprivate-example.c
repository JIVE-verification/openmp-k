#include <stdio.h>

int main() {
    int x = 100;

    printf("Before loop: x = %d\n", x);

    #pragma omp parallel for firstprivate(x)
    for (int i = 0; i < 4; i++) {
        printf("At First Line, x = %d\n", x);	    	
        x += i;
        printf("At Last Line, x = %d\n", x);
    }

    printf("After loop: x = %d\n", x);

    return 0;
}
