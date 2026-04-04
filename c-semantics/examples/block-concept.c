// Concept: What a block-based thread would look like
// This shows what OpenMP for loop body execution needs

#include <stdio.h>

int global_counter = 0;

int main(void) {
    // This is what we want to execute in multiple threads
    // for OpenMP: #pragma omp parallel for
    // for (int i = 0; i < 10; i++) { <BLOCK> }

    // The BLOCK part (loop body):
    {
        int i = global_counter;  // Each thread gets different i
        printf("Iteration %d\n", i);
        // More work here...
    }

    return 0;
}
