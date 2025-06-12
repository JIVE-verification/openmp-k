#include<stdio.h>
#include<omp.h>

int main(int argc, char *argv[]){
    int v = 0;
    # pragma omp parallel for
    for(int i = 0; i < 10; i++)
        v += 1;
    printf("%d\n",v);
    return 0;
}

