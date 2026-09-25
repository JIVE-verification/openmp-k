#include <stdio.h>
int main(void)
{
    int i = 0;
    printf("R1:\n");
    #pragma omp parallel
    {
        printf("R2:IN#1\n");
        printf("R2:IN#2\n");
    }
    printf("R3:\n");
    return 0;
}