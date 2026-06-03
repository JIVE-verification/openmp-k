#include <stdio.h>
#include <omp.h>
int main() {
    int x = 5;

    #pragma omp parallel for lastprivate(conditional: x)
    for (int i = 0; i < 9; i++) {
    	if(i < 8){
        	x = i * 2;
	}
    }

    printf(">x = %d\n", x);

    return 0;
}
