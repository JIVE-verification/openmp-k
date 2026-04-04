#include <stdio.h>
#include <omp.h>

int main(void) {
    printf("Starting OpenMP parallel for with thread distribution\n");
    printf("Expected distribution for N=15, T=3:\n");
    printf("  Thread 0: iterations [0, 1, 2, 3, 4]\n");
    printf("  Thread 1: iterations [5, 6, 7, 8, 9]\n");
    printf("  Thread 2: iterations [10, 11, 12, 13, 14]\n");
    printf("\nActual execution:\n");

    #pragma omp parallel for
    for (int i = 0; i < 15; i++) {
        int tid = omp_get_thread_num();
        printf("Thread %d executing iteration %d\n", tid, i);
    }

    printf("\nAll iterations completed\n");
    return 0;
}
