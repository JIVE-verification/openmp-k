#include <stdio.h>

int main() {
    double sum = 0.0;
    double prod = 1.0;
    #pragma omp parallel for reduction(+:sum) reduction(*:prod)
    for (int i = 1; i < 10; i++) {
        sum += i;
        prod *= i;
    }
    printf("Sum = %lf\n", sum);
    printf("Prod = %lf\n", prod);
    return sum*prod;
}
