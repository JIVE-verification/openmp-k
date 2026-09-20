#include <stdio.h>

int main() {
    double sum = 0;
    #pragma omp parallel for reduction(+:sum)
    for (int i = 1; i < 20; i++) {
        sum += i;
    }
    printf("Sum = %lf\n", sum);
    return sum;
}
