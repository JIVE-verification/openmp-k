#include <stdio.h>

#define N 115

int main() {
    int a[N];

    for (int i = 1; i < N; i++) {
        a[i] = i * i;
    }

    printf("Array: ");
    for (int i = 0; i < N; i++) printf("%d ", a[i]);
    printf("\n");
    return 0;
}
