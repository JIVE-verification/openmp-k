#include <stdio.h>

#define PI 3.14159

int dipok = 2.0;

double empty(){
    return 3.0;
}

double twice(int a){
   return a * a;
}

double area(double r) {
    return PI * r * r;
}

double circumference(double r) {
    return 2 * PI * r;
}

int main() {
    double radius = empty() * twice(2.0);
    printf("PI=%.2f, R= %.2f,A= %.2f,C= %.2f\n", PI, radius, area(radius), circumference(radius));
    return 0;
}
