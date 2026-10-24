#include <stdio.h>
#include <omp.h>
// #include "ompvv.h"

int main(void)
{   
    int n;
    n = 3;
    int s;
    omp_set_num_threads(10);
    //OMPVV_INFOMSG("Working with OpenMP_VV");
    #pragma omp parallel num_threads(n) shared(s)
    {
        // printf("Hello from thread %d, while total number of threads is %d\n", omp_get_thread_num(), omp_get_num_threads());
        #pragma omp single
        {
            int i = 0;
        }
        #pragma omp barrier
    }

    return 0;
}