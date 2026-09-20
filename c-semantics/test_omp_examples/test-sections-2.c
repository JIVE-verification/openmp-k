#include <stdio.h>
#include <omp.h>

int main() {

    #pragma omp parallel num_threads(3)
    {
        #pragma omp sections
        {
            #pragma omp section
            {
                int sum = 0;
                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Section 1: sum = %d\n", sum);
            }

            #pragma omp section
            {
                int product = 1;
                for (int i = 1; i <= 5; i++)
                    product *= i;

                printf("Section 2: product = %d\n", product);
            }

            #pragma omp section
            {
                int square = 12 * 12;

                printf("Section 3: square = %d\n", square);
            }
        }
    }

    return 0;
}
