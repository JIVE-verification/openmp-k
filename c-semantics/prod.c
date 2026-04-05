#include <stdio.h>

int main() {
    int n, prod;

    n = 0;
    prod = 1;

    while (n < 500) {
        prod = prod * n;
        n = n + 1;
    }

    printf("Hello %d\n", prod);
    return 0;
}

