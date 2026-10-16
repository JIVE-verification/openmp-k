
#include <stdio.h>

int main(void)
{
    int a = 10, b = 5;
    int sum, product;

    int *p1 = &a;
    int *p2 = &b;

    sum = *p1 + *p2;
    product = (*p1) * (*p2);

    printf("a = %d, b = %d\n", *p1, *p2);
    printf("Sum = %d\n", sum);
    printf("Product = %d\n", product);

    return 0;
}