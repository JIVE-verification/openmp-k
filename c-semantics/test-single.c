#include <stdio.h>

int main() {
    int sum = 0;

    #pragma omp parallel num_threads(4)
    {
        #pragma omp single
        {
            for (int i = 1; i <= 10; i++)
                sum += i;

            printf("Sum = %d\n", sum);
        }
    }

    return 0;
}
