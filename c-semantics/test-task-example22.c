#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(2)
    {
	    int a = 11;
            printf("Region 1,  a = %d\n", a);
            #pragma omp task
            {
		     // a = 111;
                int sum = 0;
                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Task 1: Sum = %d, a = %d\n", sum, a);
            }
	     a = 21;
            printf("Region 2,  a = %d\n", a);
            #pragma omp task
            {
		     // a = 212;
                int product = 1;
                for (int i = 1; i <= 5; i++)
                    product *= i;
                printf("Task 2: Product = %d, a = %d\n", product, a);
            }
	     a = 31;
            printf("Region 3,  a = %d\n", a);
            #pragma omp taskwait

	     a = 41;
            printf("Region 4,  a = %d\n", a);
    }
    return 0;
}
