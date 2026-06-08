#include <stdio.h>

int main() {
    int x = 0;

    #pragma omp parallel for lastprivate(x)
    for (int i = 0; i < 20; i++) {
    	if(i < 8 ){
        	x = i * 10;
        }
    }

    printf("x = %d\n", x);

    return 0;
}
