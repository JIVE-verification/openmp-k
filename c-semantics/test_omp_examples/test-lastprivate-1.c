#include <stdio.h>

int main() {
    int x = 0;

    #pragma omp parallel for lastprivate(x)
    for (int i = 0; i < 9; i++) {
        x = i * 2;
    }

    printf("x = %d\n", x);

    return 0;
}
