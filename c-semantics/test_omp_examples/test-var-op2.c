#include <stdio.h>

int main() {
    int n = 100;
    double sum1 = 0;
    double sum2 = 0;
    for(int i=0; i<n; i++){
    	sum1 += i;
    	sum2 = sum2 + i;
    }
    return (sum1+sum2)/2;
}
