#include <stdio.h>

int main() {
    int sum = 0;
    int prod = 1;
    #pragma omp parallel for reduction(+:sum) reduction(*:prod)
    for (int i = 1; i < 10; i++) {
        sum += i;
        prod *= i;
    }
    printf("Sum = %d\n", sum);
    printf("Prod = %d\n", prod);
    return sum*prod;
}
