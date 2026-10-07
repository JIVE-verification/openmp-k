#include <stdio.h>

int main() {
    int sum = 0;
    for (int i = 1; i <= 5; i++) {
        if(i %2 == 0){
            sum += i;
        }
        else{
            continue;
        }
    }
    printf("Sum = %d\n", sum);
    return sum;
}