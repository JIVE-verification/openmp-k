#include <stdio.h>

int main() {
    int x = 100;
    int sum = 0;
    #pragma omp parallel for firstprivate(x)
    for (int i = 0; i < 20; i++) {
    	x += i;
    	sum += x;
    }

    printf("OUT x = %d\n", x);
    printf("sum = %d\n", sum);
    return sum;
}
