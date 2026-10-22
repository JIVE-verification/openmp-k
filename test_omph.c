#include <stdio.h>
#include <omp.h>
#include "ompvv.h"

int main(void)
{   
    
    OMPVV_INFOMSG("Working with OpenMP_VV");
    #pragma omp parallel num_threads(2)
    {
        printf("Hello from thread %d, while total number of threads is %d\n", omp_get_thread_num(), omp_get_num_threads());
    }

    return 0;
}