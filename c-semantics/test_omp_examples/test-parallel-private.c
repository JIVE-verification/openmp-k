#include <stdio.h>

int main() {
    int x = 100;

    #pragma omp parallel private(x)
    {
        x = 10;
        printf("x = %d\n", x);
    }

    printf("After parallel region, x = %d\n", x);

    return 0;
}
