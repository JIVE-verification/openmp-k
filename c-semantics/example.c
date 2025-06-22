#include<stdio.h>
#include<omp.h>

int main(int argc, char *argv[]){
    int v = 0;
    int k = 0;
    int t = 10;
    int p = 20;
    int p2 = 30;
    #pragma omp parallel for 
    for(int i = 0; i < 10; i++)
        v += 1;
    printf("%d\n",v);
    return 0;
}

