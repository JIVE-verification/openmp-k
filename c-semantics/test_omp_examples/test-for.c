#include <stdio.h>

int main() {
    int sum = 0;

    #pragma omp parallel for
    for (int i = 100; i <= 120; i++) {
        sum += i;
    }

    printf("Sum = %d\n", sum);

    return 0;
}
