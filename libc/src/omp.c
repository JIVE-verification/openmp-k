#include <omp.h>

int omp_get_thread_num(){
    int i; 
    #pragma omph get_thread_num(i);
    return i;
}

int omp_get_num_threads(){
    int i;
    #pragma omph get_num_threads(i);
    return i; 
}

void omp_set_num_threads(int i){
    #pragma omph set_num_threads(i);
}