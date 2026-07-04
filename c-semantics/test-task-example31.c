#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(2)
    {
	    int a = 11;
            printf("Region 1,  a = %d\n", a);
            #pragma omp task
            {
                int sum = 0;
                printf("Task 1: #1 Sum = %d, a = %d\n", sum, a);
                a = 7;
                printf("Task 1: #2 Sum = %d, a = %d\n", sum, a);
            }
	     a = 21;
            printf("Region 2,  a = %d\n", a);
            #pragma omp task
            {
                int product = 1;
                printf("Task 2: Product = %d, a = %d\n", product, a);
                a=13;
            }
	     a = 31;
            printf("Region 3,  a = %d\n", a);
            #pragma omp taskwait

	     a = 41;
            printf("Region 4,  a = %d\n", a);
    }
    return 0;
}
