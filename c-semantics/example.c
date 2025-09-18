#include<stdio.h>
#include<stdlib.h>
#include</home/user/mounted/dist/profiles/x86-gcc-limited-libc/include/library/threads.h>

// int func(void * argc){
//     int* v = (int *) argc;
//     // *v = 1;
//     printf("hi\n");
//     return 0;
// }
int main(int argc, char *argv[]){
    thrd_t thr1, thr2;
    // int *v = malloc(sizeof(int));

    // thrd_create(&thr1,func,(void *) v);
    // thrd_create(&thr2,func,(void *) v);
    // #pragma omp parallel for
    for(int i = 0; i < 10; i++){
        printf("%d\n",i);
    }
    printf("hi\n");
    return 0;
}