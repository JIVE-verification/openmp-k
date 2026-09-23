#include <stdio.h>

int main(void)
{
    int i = 0;
    printf("R1:%d\n", i);
    #pragma omp parallel
    {
        i++;
        printf("R2:%d\n", i);
    }
    printf("R3:%d\n", i);
    return 0;
}