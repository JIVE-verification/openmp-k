#include<stdio.h>
#include <omp.h>
#define I 30
#define G 30
int main(int argc, char *argv[]){

    #pragma omp parallel for
    for(int i = 0; i < I; i++){
        printf("%d\n",i);
    }
        
    
    return 0;
}