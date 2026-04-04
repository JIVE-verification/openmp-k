// Thread example with mutex - demonstrates synchronization
// Maps to rules in semantics/c/library/threads.k

#include <stdio.h>
#include </home/user/mounted/c-semantics/dist/profiles/x86-gcc-limited-libc/include/library/threads.h>

// Global mutex and counter
mtx_t mutex;
int counter = 0;

// Worker thread that increments counter safely
// Demonstrates mutex usage with K semantics rules
int worker(void *arg) {
    int id = *(int *)arg;

    // Lock mutex - uses [mtx-lock] rule (threads.k:157)
    mtx_lock(&mutex);

    printf("Thread %d: Locked mutex\n", id);

    // Critical section
    int old_value = counter;
    counter = counter + 1;
    printf("Thread %d: Counter %d -> %d\n", id, old_value, counter);

    // Unlock mutex - uses [mtx-unlock] rule (threads.k:172)
    mtx_unlock(&mutex);

    printf("Thread %d: Unlocked mutex\n", id);

    return counter;
}

int main(void) {
    thrd_t thread1, thread2;
    int arg1 = 1;
    int arg2 = 2;
    int result1, result2;
    int status;

    printf("Main: Initializing mutex\n");

    // Initialize mutex - uses [mtx-init] rule (threads.k:150)
    status = mtx_init(&mutex, mtx_plain);
    if (status != thrd_success) {
        printf("ERROR: Mutex init failed\n");
        return 1;
    }

    printf("Main: Creating first thread\n");

    // Create first thread
    status = thrd_create(&thread1, worker, &arg1);
    if (status != thrd_success) {
        printf("ERROR: Thread 1 creation failed\n");
        return 1;
    }

    printf("Main: Creating second thread\n");

    // Create second thread
    status = thrd_create(&thread2, worker, &arg2);
    if (status != thrd_success) {
        printf("ERROR: Thread 2 creation failed\n");
        return 1;
    }

    printf("Main: Waiting for threads to complete\n");

    // Join both threads
    thrd_join(thread1, &result1);
    printf("Main: Thread 1 completed, result = %d\n", result1);

    thrd_join(thread2, &result2);
    printf("Main: Thread 2 completed, result = %d\n", result2);

    printf("Main: Final counter value = %d (expected 2)\n", counter);

    return 0;
}
