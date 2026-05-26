#include <stdio.h>

#define M 115

int main() {
    int b[M];

    #pragma omp parallel for
    for (int j = 0; j < M; j++) {
        a[j] = j * j;
    }
    return 0;
}
