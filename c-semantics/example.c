#include </home/user/mounted/profiles/x86-gcc-limited-libc/include/library/threads.h>
int myfunc1(void* arg){
    return 0;
}

int main(int argc, char *argv[]){
    thrd_t t1, t2;
    thrd_create(&t1, myfunc1, NULL);
    thrd_create(&t2, myfunc1, NULL);
    thrd_join(t1,NULL);
    thrd_join(t2,NULL);
    return 0;
}