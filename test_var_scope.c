#include <stdio.h>

int main(void)
{
    int i;
    i = 3;
    if(i%2 == 0){
        int i = 7; 
        printf("IN>%d\n", i);
    }
    else{
        int i = 5;
        printf("IN>%d\n", i);
    }
    printf("OUT>%d\n", i);
    return 0;
}