#include <stdio.h>
#define N 38
int main() {
    int a[N];
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        a[i] = i * i;
    }
    int sum=0;
    for(int j=0; j < N; j++){
      sum += a[j];
    }
    printf("%d", sum);
    return 0;
}
