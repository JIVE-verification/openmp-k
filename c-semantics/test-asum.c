#include <stdio.h>
#define N 98
int main() {
    int a = 0;
    int d = 1;
    int sum = 0;
    #pragma omp parallel for 
    for (int i = 0; i < N; i++) {
        int term = a;
        for (int j = 0; j < i; j++) {
            term += d;
        }
        sum += term;
    }
    printf("a=%d, d=%d, N=%d, Sum = %d\n", a, d, N, sum);
    return sum;
}
