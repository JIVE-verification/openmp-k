#include <stdio.h>
#define N 45
int main() {
    double sum = 0.0;
    #pragma omp parallel for
    for (int i = 1; i < N; i++) { // identifier ("i") < 12 => 
        sum += 1.0 / (double) i;
    }
    printf("Harmonic sum of first %d terms = %.10f\n", (N-1), sum);
    return sum;
}
