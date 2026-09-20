#include <stdio.h>

int main() {
    int total = 50;
    int x;
    x = 20;
    #pragma omp parallel
    {
        #pragma omp for reduction(+:total)
        for (int i = 0; i < 15; i++) {
            total += x * i; 
        }
        x = x * 2;
    }
    printf("total = %d\n", total);
    printf("x=%d\n", x);
    return 0;
}
