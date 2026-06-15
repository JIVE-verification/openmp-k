#include <stdio.h>

int counter1=5;
int counter2=10;

int main() {
    int a=10;
    #pragma omp parallel num_threads(4)
    {
	counter1 = counter1 + a;
	counter2 = counter2 + a;
	printf("IN> C1=%d, C2=%d\n", counter1, counter2);
    }
    printf("OUT>C1=%d, C2=%d\n", counter1, counter2);
    return 0;
}
