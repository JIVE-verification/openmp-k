#include <stdio.h>
#define N 37
int main() {
    int n = 20;              
    double e = 1.0;
    double fact = 1.0; 
    #pragma omp parallel for
    for (int i = 1; i < N; i++) {
        fact *= i;         
        e += 1.0 / fact;
    }
    printf("Approximation of e = %.15f\n", e);
    return 0;
}
