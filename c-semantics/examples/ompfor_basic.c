#include <stdio.h>

int main() {
    int i;
    #pragma omp parallel for
    for (i = 0; i < 8; ++i) {
        printf("i=%d\n", i);
    }
    return 0;
}
