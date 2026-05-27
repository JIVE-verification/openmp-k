#include <stdio.h>

#define M 15

int main() {
    int b[M];
    int n=0, k=0;
    int p=0;
    int q;
    #pragma omp parallel for private(n, p)
    for (int j = 0; j < M; j++) {
    	int d;
        b[j] = j * j;
    }
    return 0;
}
