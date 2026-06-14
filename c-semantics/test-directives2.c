#include <stdio.h>

#define PI 3.14159

double area(double r) {
    return PI * r * r;
}

double circumference(double r) {
    return 2 * PI * r;
}

int main() {
    double radius = 5.0;

    printf("R= %.2f\n", radius);
    printf("A= %.2f\n", area(radius));
    printf("C= %.2f\n", circumference(radius));

    return 0;
}
