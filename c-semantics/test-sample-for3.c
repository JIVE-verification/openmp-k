#include <stdio.h>

int main() {
    int N = 115;
    int a[N];
    #pragma omp parallel for
    for (int i = 0; i < N; i++)
        a[i] = i * i;
    
    int sum = 0;
    for (int i = 0; i < N; i++) 
        sum += a[i];

    printf("%d", sum);
    return sum;
}
