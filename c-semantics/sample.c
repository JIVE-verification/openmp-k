#include <stdio.h>

int process(int limit) {
    int total = 0;

    for (int i = 0; i < limit; i++) {
        int counter = i;
        int value;

        if (i % 2 == 0) {
            value = i * 2;
        } else {
            value = i + 5;
        }

        while (counter > 0) {
            if (counter % 2 == 0) {
                if (counter > 2) {
                    total += counter;
                } else {
                    total -= counter;
                }
            } else {
                total += 1;
            }
            counter--;
        }
    }

    return total;
}

int main() {

    int a = 10;
    int b = 3;
    int c;
    int result;
    
    c = a * b + (a - b);

    if (c > 20) {
        c = c - 5;
    } else {
        c = c + 5;
    }

    result = process(4);
    result = result + c;

    printf("Final result = %d\n", result);

    return 0;
}

