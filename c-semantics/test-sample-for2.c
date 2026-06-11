#include <stdio.h>

int main() {
    int N = 115;
    int a[N];
    int t;
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        t = i * i; 
        a[i] = t;
    }
    int sum = 0;
    for (int i = 0; i < N; i++) {
    	t = a[i];
        sum += t;
    }
    printf("%d", sum);
    return sum;
}
