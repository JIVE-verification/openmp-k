#include <stdio.h>

int main(void) {
    printf("Testing OpenMP Post expression execution\n");

    // Simple test: verify Post expression (i++) executes
    // Each thread should process its iterations correctly
    #pragma omp parallel for
    for (int i = 2; i < 16; i++) {
        // Just print - the Post expression i++ should happen after this
        printf("Iteration %d\n", i);
    }

    printf("Done\n");
    return 0;
}
