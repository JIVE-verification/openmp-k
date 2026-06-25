#include <stdio.h>
#include <omp.h>

int main() {

    #pragma omp parallel num_threads(2)
    {
        #pragma omp task
        {
            printf("Task 1 executed by thread %d\n",
                   omp_get_thread_num());
        }
        printf("Hi, here!\n");

        #pragma omp task
        {
            printf("Task 2 executed by thread %d\n",
                   omp_get_thread_num());
        }

        #pragma omp taskwait
    }

    printf("Main thread finished\n");

    return 0;
}
