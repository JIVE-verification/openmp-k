#include <stdio.h>

int main() {
    int sum = 0;
    int a = 1; 
    #pragma omp parallel num_threads(4) firstprivate(a)
    {
        sum += 10;
        a += sum;
    	printf("IN: a = %d\n", a);
    }

    printf("sum = %d\n", sum);
    printf("OUT: a = %d\n", a);
    return 0;
}
