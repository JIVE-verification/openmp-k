#include <stdio.h>

int main(void) {
    printf("Testing OpenMP with symbolic bounds\n");

    int start = 2;
    int end = 10;

    printf("Loop from %d to %d (should execute 8 iterations)\n", start, end);

    #pragma omp parallel for
    for (int i = start; i < end; i++) {
        printf("Iteration %d\n", i);
    }

    printf("Done\n");
    return 0;
}
