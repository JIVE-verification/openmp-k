#include <stdio.h>

int counter = 0;

void increment() {
    counter++;
}

int main(void) {
    printf("Testing OpenMP with Post expression side effects\n");

    // Test that Post expression (i++) is executed
    #pragma omp parallel for
    for (int i = 0; i < 8; i++) {
        printf("Iteration %d\n", i);
        // Post expression should increment i after each iteration
    }

    // Test with function call in Post
    printf("\nTesting with function call in Post\n");
    int j;
    #pragma omp parallel for
    for (j = 0; j < 4; j++, increment()) {
        printf("j=%d, counter before=%d\n", j, counter);
    }

    printf("Final counter=%d (should be 4 for 4 iterations)\n", counter);
    printf("Done\n");
    return 0;
}
