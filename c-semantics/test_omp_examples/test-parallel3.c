#include <stdio.h>

int main() {
    int sum = 0;

    #pragma omp parallel
    {
        sum += 10;
    }

    printf("sum = %d\n", sum);

    return 0;
}
