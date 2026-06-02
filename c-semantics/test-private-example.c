#include <stdio.h>
#include <omp.h>

int main() {
    int x = 100;

    printf("Before loop: x = %d\n", x);

    #pragma omp parallel for private(x)
    for (int i = 0; i < 4; i++) {
        printf("At First Line, Thread %d: x = %d\n",
               omp_get_thread_num(), x);	    	
        x += i;
        printf("At Last Line, Thread %d: x = %d\n",
               omp_get_thread_num(), x);    }

    printf("After loop: x = %d\n", x);

    return 0;
}
