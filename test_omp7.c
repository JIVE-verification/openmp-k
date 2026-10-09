#include <stdio.h>

int main(void)
{
    int i;
    i = 7; 
    #pragma omp parallel num_threads(2)
    {
        i = 3; 
        i  = i - 3;
    }
    return i;
}