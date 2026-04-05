#include <stdio.h>

int main() {
    int n = 1234, rev = 0;
    while (n != 0) {
        rev = rev * 10 + n % 10;
        n /= 10;
    }
    printf("Reversed = %d\n", rev);
    return 0;
}

