#include <stdio.h>

int main() {
    int x = 100;

    #pragma omp parallel for firstprivate(x)
    for (int i = 0; i < 20; i++) {
        x += i;
    }

    printf("x = %d\n", x);

    return 0;
}
