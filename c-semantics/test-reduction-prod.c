#include <stdio.h>

int main() {
    int prod = 1;
    #pragma omp parallel for reduction(*:prod)
    for (int i = 1; i < 20; i++) {
        prod *= i;
    }
    printf("Prod = %d\n", prod);
    return prod;
}
