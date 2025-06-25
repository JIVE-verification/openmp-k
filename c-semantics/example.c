#include <omp.h>
#include <stdio.h>

int main(int argc, char *argv[]){
    int v = 0;
    int k = 20;
    int t = 30;
    #pragma omp parallel for
    for(int i = 0; i < 10; i++){
        v += 1;
    }
    printf("%d\n",v);

    return 0;
}