#include <stdio.h>

#define PI 3.14159
#define SQUARE(x) ((x) * (x))

int main() {
    int n = 5;

    printf("PI = %f\n", PI);
    printf("Square of %d = %d\n", n, SQUARE(n));

    return 0;
}
