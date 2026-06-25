#include <stdio.h>
#include <omp.h>
int main() {
    #pragma omp parallel num_threads(3)
    {
        int n = 0;

    	#pragma omp single 
    	{
//    		int n = 0;
		#pragma omp task shared(n)
		{
			//n=4;
			printf("Hello 1, n=%d From %d\n", n, omp_get_thread_num());
			#pragma omp task
			{
				// n=6;
				// variables are first private
				printf("Hello 2 n=%d from %d\n", n, omp_get_thread_num());
			}
			n=5;
			#pragma omp task
			{
				
				printf("Hello 3 n=%d from %d\n", n, omp_get_thread_num());
			}
			
		}
		
		#pragma omp task shared(n)
		{
//			//n = 7;
			printf("Hello 4 n=%d From %d\n", n, omp_get_thread_num());
		}

		n = 9; 
		#pragma omp taskwait

		#pragma omp task
		printf("Goodbye. From %d\n", omp_get_thread_num());
   	}
    }

    return 0;
}
