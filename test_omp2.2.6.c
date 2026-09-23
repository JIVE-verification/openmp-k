#include <stdio.h>

int main(void)
{
    int i = 0;
    printf("R1@OUT:%d\n", i);
    #pragma omp parallel
    {
        i++;
        printf("R2@IN:%d\n", i);
    }
    printf("R3@dipokcd@OUT:%d\n", i);
    return 0;
}