#include <stdio.h>
#define N 55
int main() {
    int a[N];
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        a[i] = i * i;
    }
    return 0;
}
