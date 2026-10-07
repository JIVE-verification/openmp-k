#include <stdio.h>

int main(void)
{
    int i;
    i = 7; 
    printf("R1: %d\n",i);
    #pragma omp parallel private(i) num_threads(2)
    {
        i = 3; 
        printf("R2: %d\n", i);
    }
    printf("R3: %d\n", i);
    return 0;
}