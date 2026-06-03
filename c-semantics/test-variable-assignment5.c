#include <stdio.h>

int main() {
    int x = 100;
    if(x%2==0){
    	int x = x;
    	x = 2;
    	printf("IN:%d\n", x); 	
    }
    else{
    	int x = x;
    	x = 1;
    	printf("IN%d\n", x);
    }
    
    printf("x = %d\n", x);
    return x;
}
