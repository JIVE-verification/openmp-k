#include <stdio.h>
#include <omp.h>
// blockOmpParallel(Int, B, A, BeforeFor, blockOmpFor(), AfterFor) => 
int main() {

    #pragma omp parallel num_threads(7)
    {
       int temp; 
       #pragma omp for 
       for (int i = 0; i < 10; i++) {        	
       	temp = i * i;
		printf("%d", temp);	
        }
    }
    return 0;
}



