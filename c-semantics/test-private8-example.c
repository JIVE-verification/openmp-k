#include <stdio.h>

int main() {
    int x = 100;
    int y = 50;
    
    #pragma omp parallel for private(x) firstprivate(y)
    for (int i = 0; i < 20; i++) {
    	y = y + 1;
    	x = y + i;
    	printf("x=%d,y=%d\n",x,y); 
    }
    printf("<y = %d",y);
    printf("x = %d>\n", x);

    return 0;
}
