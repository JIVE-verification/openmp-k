#include <stdio.h>
#include <omp.h>

int main() {

    #pragma omp parallel num_threads(4)
    {
        int tid = omp_get_thread_num();

        /* Computation done by all threads */
        int sum = 0;
        for (int i = 0; i < 1000; i++) {
            sum += i;
        }
	
        printf("Thread %d finished sum=%d computation\n", omp_get_thread_num(), sum);

        #pragma omp single
        {
            printf("Thread %d creating tasks\n", omp_get_thread_num());

            #pragma omp task
            {
                long x = 0;
                for (int i = 0; i < 5000000; i++)
                    x += i;

                printf("Task 1 executed by thread %d\n",
                       omp_get_thread_num());
            }
            
            printf("Man in the Midddle at Thread %d\n", omp_get_thread_num());

            #pragma omp task
            {
                long y = 1;
                for (int i = 1; i < 20; i++)
                    y *= i;

                printf("Task 2 executed by thread %d\n",
                       omp_get_thread_num());
            }

             #pragma omp taskwait

            printf("All tasks completed\n");
        }

        /* More computation by all threads */
        int prod = 1;
        for (int i = 1; i <= 10; i++) {
            prod *= i;
        }

        printf("Thread %d finished product=%d computation\n", omp_get_thread_num(), prod);
    }

    return 0;
}
