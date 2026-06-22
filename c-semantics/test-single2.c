#include <stdio.h>

int main() {
    int sum = 0;
    int product = 1;

    #pragma omp parallel num_threads(4)
    {
        #pragma omp single
        {
            for (int i = 1; i <= 10; i++)
                sum += i;

            printf("Sum = %d\n", sum);
        }

        #pragma omp single
        {
            for (int i = 1; i <= 5; i++)
                product *= i;

            printf("Product = %d\n", product);
        }
    }

    return 0;
}
