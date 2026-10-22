#include <omp.h>

int omp_get_thread_num(){
    int i; 
    #pragma omp get_thread_num(i);
    return i;
}

int omp_get_num_threads(){
    int i;
    #pragma omp get_num_threads(i);
    return i; 
}