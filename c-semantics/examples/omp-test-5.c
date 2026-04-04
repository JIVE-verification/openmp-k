// Test OpenMP parallel for with 5 iterations
#include <stdio.h>

int main(void) {
    printf("Testing 5 iterations\n");

    #pragma omp parallel for
    for (int i = 0; i < 5; i++) {
        printf("Iteration %d\n", i);
    }

    printf("Done\n");
    return 0;
}
