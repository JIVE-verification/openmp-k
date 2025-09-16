#include<stdio.h>
int i = 0;
int main(int argc, char *argv[]){

    #pragma omp parallel for
    for(i = 0; i < 10; i++){
        printf("%d\n",i);
    }
    return 0;
}