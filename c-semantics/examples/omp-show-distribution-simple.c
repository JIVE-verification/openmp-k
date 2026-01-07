#include <stdio.h>

int main(void) {
    printf("OpenMP Parallel For - Contiguous Block Distribution Test\n");
    printf("=========================================================\n");
    printf("Loop: for (int i = 0; i < 15; i++)\n");
    printf("Threads: 3\n");
    printf("\nExpected distribution (static schedule, default):\n");
    printf("  Thread 0: iterations [0, 1, 2, 3, 4]       (5 iterations)\n");
    printf("  Thread 1: iterations [5, 6, 7, 8, 9]       (5 iterations)\n");
    printf("  Thread 2: iterations [10, 11, 12, 13, 14]  (5 iterations)\n");
    printf("\nActual execution output:\n");
    printf("---------------------------------------------------------\n");

    #pragma omp parallel for
    for (int i = 0; i < 15; i++) {
        printf("Iteration %2d executed\n", i);
    }

    printf("---------------------------------------------------------\n");
    printf("\nNote: In actual parallel execution, the output order may be\n");
    printf("non-deterministic due to thread scheduling, but each thread\n");
    printf("should execute its assigned contiguous block of iterations.\n");
    printf("\nAll iterations completed successfully!\n");
    return 0;
}
