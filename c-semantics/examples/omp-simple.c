// Simple OpenMP parallel for test
// Tests block-based threading with spawn-block-aux

#include <stdio.h>

int main(void) {
    printf("Starting OpenMP parallel for test\n");

    // This should execute iterations in parallel threads
    #pragma omp parallel for
    for (int i = 0; i < 15; i++) {
        printf("Thread executing iteration %d\n", i);
    }

    printf("All iterations completed\n");
    return 0;
}
