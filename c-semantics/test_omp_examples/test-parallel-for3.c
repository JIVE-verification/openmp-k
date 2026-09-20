#include <stdio.h>

int main() {
    int total = 0;
    #pragma omp parallel
    {
        int x;
        x = 10;
        #pragma omp for reduction(+:total)
        for (int i = 1; i <= 5; i++) {
            total += x * i; 
        }
        x = x * 2;
    }
    printf("total = %d\n", total);
    return 0;
}
