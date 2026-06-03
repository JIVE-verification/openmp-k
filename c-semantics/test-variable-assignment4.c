#include <stdio.h>

int main() {
    int x = 100;
    if(x%2==0){
    	int x = 0;
    	printf("IN:%d\n", x); 	
    }
    else{
    	printf("IN%d\n", x);
    }
    
    printf("x = %d\n", x);
    return x;
}
