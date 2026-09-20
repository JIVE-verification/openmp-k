#include <stdio.h>

#define M 115

int main() {
    int b[M];
    int n=0;
    #pragma omp parallel for private(n)
    for (int j = 0; j < M; j++) {
        b[j] = j * j;
    }
    return 0;
}
