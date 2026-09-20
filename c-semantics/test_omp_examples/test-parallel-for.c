#include <stdio.h>

int main() {

    #pragma omp parallel num_threads(3)
    {
       int temp; 
       #pragma omp for 
       for (int i = 0; i < 10; i++) {        	
       	temp = i * i;
		printf("%d\n", temp);	
        }
    }
    return 0;
}



