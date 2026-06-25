#include <stdio.h>
#include <omp.h>

int main() {
    #pragma omp parallel num_threads(5)
    #pragma omp single nowait
    {
        printf("Task Created from %d\n", omp_get_thread_num());
        int num=0;
        #pragma omp task
        {
        	printf("Task Executed from %d\n", omp_get_thread_num());
        	num=2;
        	printf("Value of num=%d from %d\n", num, omp_get_thread_num());
        }
        num=3;
        printf("Random Statement from %d\n", omp_get_thread_num());
    }
    return 0;
}
