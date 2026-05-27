#include <stdio.h>

#define M 15

int main() {
    int b[M];
    int n=0, k=0;
    int p=0;
    #pragma omp parallel for private(n, k)
    for (int j = 0; j < M; j++) {
        b[j] = j * j;
    }
    return 0;
}
