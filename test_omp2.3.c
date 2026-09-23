#include <stdio.h>

int main(void)
{
    int i = 0;
    printf("R1:\n", i);
    #pragma omp parallel
    {
        // i++;
        printf("R2:%d\n", i);
    }
    printf("R3:\n", i);
    return 0;
}