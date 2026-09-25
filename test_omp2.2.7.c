#include <stdio.h>

int main(void)
{
    int i = 0;
    printf("R1@OUT:%d\n", i);
    #pragma omp parallel
    {
        i++;
        printf("R2@IN#1:%d\n", i);
        printf("R2@IN#2:%d\n", i);
    }
    printf("R3@@OUT:%d\n", i);
    return 0;
}