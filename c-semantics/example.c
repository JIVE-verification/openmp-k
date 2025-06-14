#include<stdio.h>
#include<omp.h>
int new (){return 0;}

int main(int argc, char *argv[]){
    int v = 0;
    for(int i = 0; i < 10; i++)
        v += 1;
    printf("%d\n",v);
    return 0;
}

