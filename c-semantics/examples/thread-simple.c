// Simple thread example - demonstrates basic K thread semantics
// Maps to rules in semantics/c/library/threads.k

#include <stdio.h>
#include </home/user/mounted/c-semantics/dist/profiles/x86-gcc-limited-libc/include/library/threads.h>

// Global variable to pass to thread (avoids thread storage duration warning)
int global_input = 21;

// Worker thread function
// Matches: Call(ThFuncPtr, list(ListItem(ThArg))) at threads.k:82
int worker(void *arg) {
    int value = *(int *)arg;

    // Uses [thrd-current] rule (threads.k:96)
    thrd_t my_id = thrd_current();

    printf("Worker thread %d: processing value %d\n", my_id, value);

    // Return value will be captured by thrd_join
    return value * 2;
}

int main(void) {
    thrd_t thread;
    int result;
    int status;

    printf("Main: Starting with input = %d\n", global_input);

    // Create thread
    // Uses [thrd-create-start] (threads.k:54) and [thrd-create] (threads.k:65)
    status = thrd_create(&thread, worker, &global_input);

    if (status != thrd_success) {
        printf("ERROR: Thread creation failed\n");
        return 1;
    }

    printf("Main: Thread created successfully\n");

    // Join thread and get result
    // Uses [thrd-join-start] (threads.k:105) and [thrd-join] (threads.k:110)
    status = thrd_join(thread, &result);

    if (status != thrd_success) {
        printf("ERROR: Thread join failed\n");
        return 1;
    }

    printf("Main: Thread completed with result = %d\n", result);
    printf("Main: Expected %d * 2 = %d\n", global_input, global_input * 2);

    return 0;
}
