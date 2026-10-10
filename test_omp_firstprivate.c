
#include <stdio.h>

int main() {
    int x = 10;
    int y = 0; 
    #pragma omp parallel firstprivate(x) num_threads(2)
    {
        y = x + 10;
    }
    return y;
}