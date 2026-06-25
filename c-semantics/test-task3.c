#include <stdio.h>
#include <omp.h>
int main() {
    #pragma omp parallel
    {
    	int n = 0;
        #pragma omp task
        printf("Hello. From %d\n", omp_get_thread_num());

        #pragma omp taskwait

        #pragma omp task
        printf("Goodbye. From %d\n", omp_get_thread_num());
    }

    return 0;
}
