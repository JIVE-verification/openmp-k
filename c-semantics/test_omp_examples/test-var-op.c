#include <stdio.h>

int main() {
    int n = 100;
    int sum1 = 0;
    int sum2 = 0;
    for(int i=0; i<n; i++){
    	sum1 += i;
    	sum2 = sum2 + i;
    }
    return (sum1+sum2)/2;
}
