#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <N>\n", argv[0]);
        return 1;
    }

    long N = atol(argv[1]);

    volatile uint64_t a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8;

    for (long i = 0; i < N; i++) {
        a = a * 3 + 1;
        b = b * 5 + 2;
        c = c * 7 + 3;
        d = d * 11 + 4;
        e = e * 13 + 5;
        f = f * 17 + 6;
        g = g * 19 + 7;
        h = h * 23 + 8;
    }

    printf("%llu\n", (unsigned long long)(a+b+c+d+e+f+g+h));
    return 0;
}
