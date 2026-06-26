#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(2)
    {
    	int n = 0;
        #pragma omp task
        {
            n=10;
            printf("Task 1, n=%d\n", n);
        }

        for (int i = 0; i < 5; i++) { }
        
        #pragma omp task
        {
            printf("Task 2, n=%d\n", n);
        }

        #pragma omp taskwait
    }

    return 0;
}
