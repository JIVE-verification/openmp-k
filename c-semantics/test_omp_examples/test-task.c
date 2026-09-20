#include <stdio.h>
#include <omp.h>

int main() {
    int a = 0;
    int b = 0;

    #pragma omp parallel num_threads(4)
    {
        #pragma omp single
        {
            #pragma omp task
            {
                a = 10 * 10;
            }

            #pragma omp task
            {
                b = 20 * 20;
            }

            #pragma omp taskwait

            printf("a = %d\n", a);
            printf("b = %d\n", b);
            printf("a + b = %d\n", a + b);
        }
    }

    return 0;
}
