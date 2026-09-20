#include <stdio.h>

int compute(int n) {
    int sum = 0;
    for (int i = 1; i <= n; i++) {
        sum += i;
    }
    return sum;
}

int main() {
    int n = 10;
    int result = compute(n);
    return result;
}
