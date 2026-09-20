#include <stdio.h>

int main() {
    int sum = 0;
    
    #pragma omp parallel num_threads(4)
    {
        sum += 10;
    }

    printf("sum = %d\n", sum);

    return 0;
}
