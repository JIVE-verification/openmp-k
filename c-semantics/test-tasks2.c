#include <stdio.h>
#include <omp.h>

int main() {

    #pragma omp parallel num_threads(4)
    {
        #pragma omp single
        {
            printf("Creating tasks... by thread %d\n", omp_get_thread_num());
	    int c = 11;
	    printf("%d by thread %d\n", c, omp_get_thread_num());
            #pragma omp task
            {
                int sum = 0;
                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Task 1: sum = %d (thread %d)\n",
                       sum, omp_get_thread_num());
		     int c = 7;
		     printf("%d by thread %d\n", c, omp_get_thread_num());
            }

            #pragma omp task
            {
                int product = 1;
                for (int i = 1; i <= 5; i++)
                    product *= i;

                printf("Task 2: product = %d (thread %d)\n",
                       product, omp_get_thread_num());
            	     int c = 3;
	     printf("%d by thread %d\n", c, omp_get_thread_num());

		}
	     c = 2;
	     printf("%d by thread %d\n", c, omp_get_thread_num());

            #pragma omp task
            {
                int square = 12 * 12;

                printf("Task 3: square = %d (thread %d)\n",
                       square, omp_get_thread_num());
                	     int c = 5;
	     printf("%d by thread %d\n", c, omp_get_thread_num());
       
            }

            #pragma omp taskwait

            printf("All tasks completed\n");
        }
    }

    return 0;
}
