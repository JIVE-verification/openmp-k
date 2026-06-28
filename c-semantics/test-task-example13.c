#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(2)
    {
	    int a = 11;
	    int b = 12;
	    int c = 13;

            printf("Region 1,  a = %d, b = %d, c = %d\n", a, b, c);

            #pragma omp task
            {
		     a = 111;
		     b = 121;
		     c = 131;
                int sum = 0;

                for (int i = 1; i <= 10; i++)
                    sum += i;

                printf("Task 1: Sum = %d, a = %d, b = %d, c = %d\n", sum, a, b, c);
            }

	     a = 21;
	     b = 22;
	     c = 23;

            printf("Region 2,  a = %d, b = %d, c = %d\n", a, b, c);

            #pragma omp task
            {
		     a = 212;
		     b = 222;
		     c = 232;            	
                int product = 1;

                for (int i = 1; i <= 5; i++)
                    product *= i;

                printf("Task 2: Product = %d, a = %d, b = %d, c = %d\n", product, a, b, c);
            }

	     a = 31;
	     b = 32;
	     c = 33;

            printf("Region 3,  a = %d, b = %d, c = %d\n", a, b, c);

            #pragma omp taskwait

	     a = 41;
	     b = 42;
	     c = 43;

            printf("Region 4,  a = %d, b = %d, c = %d\n", a, b, c);
    }

    return 0;
}
