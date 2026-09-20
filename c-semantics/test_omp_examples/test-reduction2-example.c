#include <stdio.h>

int main() {
    int sum = 0;
    int prod = 1;

    #pragma omp parallel for reduction(+:sum) reduction(*:prod)
    for (int i = 1; i <= 5; i++) {
        sum += i;
        prod *= i;
    }

    printf("sum  = %d\n", sum);
    printf("prod = %d\n", prod);

    return 0;
}
