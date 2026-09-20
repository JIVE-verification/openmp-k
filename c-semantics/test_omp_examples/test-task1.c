#include <stdio.h>

int main() {
    int number = 1;
    #pragma omp parallel num_threads(3)
    {
        //#pragma omp task
        //{
            printf("I think the number is %d.\n", number);
            number++;
        //}
//        #pragma omp taskwait 
//        number = 2;
    }
    return 0;
}
