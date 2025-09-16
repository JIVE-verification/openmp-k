#include<stdio.h>
#include<stdlib.h>
int i = 0;
int main(int argc, char *argv[]){
    // int *i = malloc(sizeof(int));
    #pragma omp parallel for
    for(i = 0; i < 10; i++){
        printf("%d\n",i);
    }
    return 0;
}