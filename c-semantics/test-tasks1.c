#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(4) // test
    {
        #pragma omp single
        {
            #pragma omp task
            {
                int sum = 0;

                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Task 1: sum = %d\n", sum);
            }

            #pragma omp task
            {
                int product = 1;

                for (int i = 1; i <= 5; i++)
                    product *= i;

                printf("Task 2: product = %d\n", product);
            }

            #pragma omp task
            {
                int square = 12 * 12;

                printf("Task 3: square = %d\n", square);
            }

            #pragma omp taskwait

            printf("All tasks completed\n");
        }
        
        #pragma omp barrier
        printf("Threads passed the barrier\n");
    }

    return 0;
}
