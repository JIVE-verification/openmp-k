//#include <omp.h>
#include <stdio.h>
//#include <threads.h>
#include </home/user/mounted/profiles/x86-gcc-limited-libc/include/library/threads.h>

int myfunc1(void* arg){
    int v = 0;
    // for(int i = 0; i < 10; i++){
    //     v += 1;
    // }
    printf("%d\n",v);
    return 0;
}

int main(int argc, char *argv[]){
    int v = 0;
    int k = 20;
    int t = 30;
    //  thrd_t t1, t2;
    //  thrd_create(&t1, myfunc1, NULL);
    //  thrd_create(&t2, myfunc1, NULL);
    #pragma omp parallel for 
    for(int i = 0; i < 10; i++){
       v+=1;
       printf("%d\n",i);
    }
    printf("%d\n",v);

     //thrd_join(t1,NULL);
     //thrd_join(t2,NULL);
    return 0;
}