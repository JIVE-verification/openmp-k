#include <stdio.h>

int main() {
    int x = 10;

    #pragma omp parallel lastprivate(x)
    {
        for (int i = 0; i < 8; i++) {
            x += i;
        }
        printf("Inside x = %d\n", x);
    }

    printf("Outside loop: x = %d\n", x);

    return 0;
}
