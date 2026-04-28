#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static void shuffle(int *arr, int n) {
    for (int i = n - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        int tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }
}

int main(int argc, char **argv) {
    if (argc != 3) {
        printf("Usage: %s <N> <iters>\n", argv[0]);
        return 1;
    }

    int N = atoi(argv[1]);
    long iters = atol(argv[2]);

    int *arr = (int *)malloc(N * sizeof(int));
    int *perm = (int *)malloc(N * sizeof(int));

    if (!arr || !perm) return 1;

    // initialize permutation
    for (int i = 0; i < N; i++) {
        perm[i] = i;
    }

    srand(42);
    shuffle(perm, N);

    // build random pointer chain
    for (int i = 0; i < N - 1; i++) {
        arr[perm[i]] = perm[i + 1];
    }
    arr[perm[N - 1]] = perm[0];

    volatile int idx = perm[0];
    volatile int sum = 0;

    for (long i = 0; i < iters; i++) {
        idx = arr[idx];
        sum += idx;
    }

    printf("%d\n", sum);

    return 0;
}
