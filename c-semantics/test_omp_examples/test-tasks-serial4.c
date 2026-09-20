#include <stdio.h>

int main() {

    #pragma omp task
    {
        printf("Task 1 executed by thread \n");
    }
    printf("Hi, here!\n");
    #pragma omp taskwait
    
    #pragma omp task
    {
        printf("Task 2 executed by thread \n");
    }

    printf("Hi, here!\n");


    printf("Main thread finished\n");

    return 0;
}
