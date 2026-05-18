#include <stdio.h>
#define N 23
int main() {
    int a = 1;
    int r = 2;
    int sum = 0;
    #pragma omp parallel for 
    for (int i = 0; i < N; i++) {
        int term = a;
        for (int j = 0; j < i; j++) {
            term *= r;
        }
        sum += term;
    }
    printf("a=%d, r=%d, N=%d, Sum = %d\n", a, r, (N-1), sum);
    return sum;
}
