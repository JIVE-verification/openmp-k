#include <stdio.h>

int counter1 = 5;
int counter2 = 10;

#pragma omp threadprivate(counter1, counter2)

int main() {
    int a = 10;
    #pragma omp parallel num_threads(4)
    {
    	int counter1=7;
    	int counter2=3;
        for (int i = 0; i < 3; i++) {
            counter1 = counter1 + a + i;
            counter2 = counter2 + a + i;
        }
        printf("IN> C1=%d, C2=%d\n", counter1, counter2);
    }
    printf("OUT> C1=%d, C2=%d\n", counter1, counter2);
    return 0;
}
