#include <stdio.h>

int main() {
    int x = 5;
    int y = 4;

    #pragma omp parallel private(y)
    {
        int local = 5;

        local += x;
	 printf("Final x = %d\n", local);
	 x = local;
    }

    printf("Final x = %d\n", x);

    return 0;
}

