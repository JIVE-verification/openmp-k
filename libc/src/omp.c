#include <omp.h>

int omp_get_thread_num(){
    int i; 
    #pragma omp thread_num(i);
    return i;
}