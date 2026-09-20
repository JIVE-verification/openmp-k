#include <stdio.h>

#define M 15

int main() {
    int b[M];
    float n=0, k=0;
    float p=0;
    int q;
    #pragma omp parallel for private(n, p) num_threads(5)
    for (int j = 0; j < M; j++) {
    	int d;
        b[j] = j * j;
    }
    return 0;
}
