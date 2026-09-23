#include <stdio.h>

int main(void)
{
    // int i = 0;
    printf("R1:\n");
    #pragma omp parallel
    {
        // i++;
        printf("R2:\n");
    }
    printf("R3:\n");
    return 0;
}