// Simple demo: compare normal for loop vs for loop work split across threads

#include <stdio.h>
#include </home/user/mounted/c-semantics/dist/profiles/x86-gcc-limited-libc/include/library/threads.h>

#define TOTAL_ITERS 15
#define NUM_THREADS 3

typedef struct {
    int start;
    int end;
} thread_args_t;

// Worker for the "parallel for" style loop
// Each thread prints the iterations it is responsible for
int worker(void *arg) {
    thread_args_t *args = (thread_args_t *)arg;

    thrd_t my_id = thrd_current();

    for (int i = args->start; i < args->end; i++) {
        printf("[thread %d] iteration %d\n", my_id, i);
    }

    // return how many iterations this thread ran
    return args->end - args->start;
}

int main(void) {
    printf("=== Sequential for loop ===\n");

    for (int i = 0; i < TOTAL_ITERS; i++) {
        printf("[main] iteration %d\n", i);
    }

    printf("\n=== Parallel-style for loop with %d threads ===\n", NUM_THREADS);

    thrd_t threads[NUM_THREADS];
    thread_args_t args[NUM_THREADS];

    int base = TOTAL_ITERS / NUM_THREADS;
    int rem  = TOTAL_ITERS % NUM_THREADS;

    int current = 0;

    // assign contiguous blocks of iterations to each thread
    for (int t = 0; t < NUM_THREADS; t++) {
        int block = base + (t < rem ? 1 : 0); // first 'rem' threads get one extra
        args[t].start = current;
        args[t].end   = current + block;
        current       = args[t].end;

        if (thrd_create(&threads[t], worker, &args[t]) != thrd_success) {
            printf("ERROR: thread %d creation failed\n", t);
            return 1;
        }
    }

    // join threads and collect how many iterations each ran
    int total_done = 0;
    for (int t = 0; t < NUM_THREADS; t++) {
        int result = 0;
        if (thrd_join(threads[t], &result) != thrd_success) {
            printf("ERROR: thread %d join failed\n", t);
            return 1;
        }
        printf("[main] thread %d reported %d iterations\n", t, result);
        total_done += result;
    }

    printf("\n[main] total iterations done by threads = %d (expected %d)\n",
           total_done, TOTAL_ITERS);

    return 0;
}
