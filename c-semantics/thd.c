#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

void* worker(void* arg)
{
    int id = *(int*)arg;

    printf("Hello from thread %d\n", id);

    pthread_exit(NULL);
}

int main()
{
    int NUM_THREADS=3;
    // pthread_t threads[NUM_THREADS];
    int ids[NUM_THREADS];

    for (int i = 0; i < NUM_THREADS; i++) {
        ids[i] = i;
        if (pthread_create(&threads[i], NULL, worker, &ids[i]) != 0) {
            perror("pthread_create");
            exit(1);
        }
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All threads finished.\n");
    return 0;
}

