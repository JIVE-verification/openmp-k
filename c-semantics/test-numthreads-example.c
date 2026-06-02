#include <stdio.h>

int main() {
    int j=5;
    #pragma omp parallel for num_threads(10) private(j)
    for (int i = 0; i < 12; i++) {
        printf("Iteration %d \n", i);
    }

    return 0;
}
