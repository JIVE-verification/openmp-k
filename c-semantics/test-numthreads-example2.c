#include <stdio.h>

int main() {
    #pragma omp parallel for num_threads(4)
    for (int i = 0; i < 12; i++) {
        printf("Iteration %d \n", i);
    }

    return 0;
}
