#include <stdio.h>

int main(void) {
    printf("Testing with 10 iterations\n");

    #pragma omp parallel for
    for (int i = 0; i < 10; i++) {
        printf("Iteration %d\n", i);
    }

    printf("Done\n");
    return 0;
}
