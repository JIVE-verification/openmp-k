#include <stdio.h>

int main(void)
{
    #pragma omp parallel for
    for (int i = 0; i < 5; i++) {
        printf("%d\n", i);
    }

    return 0;
}