#include <stdio.h>
#include <omp.h>

int main() {

    #pragma omp parallel num_threads(3)
    {  
       #pragma omp section
            {
                int sum = 0;
                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Section 1: sum = %d\n", sum);
            }
    }

    return 0;
}
