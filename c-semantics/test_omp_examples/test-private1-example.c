#include <stdio.h>
#include <omp.h>

int main() {
    int x = 100;

    #pragma omp parallel for private(x)
    for (int i = 0; i < 20; i++) {
    	x = 0;
    	x+= i;
    }

    printf("x = %d\n", x);

    return 0;
}
