#include <stdio.h>

int counter1 =0;
int counter2=0;

#pragma omp threadprivate(counter1, counter2)

int main() {
    #pragma omp parallel num_threads(4)
    {
        int c = 0; 
    }
    return 0;
}
