#include <stdio.h>

int main() {
    int x = 5;
    int y = 4;

    #pragma omp parallel shared(x) private(y)
    {
        // each thread performs some computation
        int local = 5;   // same value in every thread

        local += x;
	 printf("Final x = %d\n", local);
	 x = local;
    }

    printf("Final x = %d\n", x);

    return 0;
}
