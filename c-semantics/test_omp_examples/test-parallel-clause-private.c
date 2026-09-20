#include <stdio.h>

int main() {
    int sum = 0;
    int a = 0; 
    #pragma omp parallel num_threads(4) private(a)
    {
        sum += 10;
        a += sum;
    	printf("IN: a = %d\n", a);
    }

    printf("sum = %d\n", sum);
    printf("OUT: a = %d\n", a);
    return 0;
}
