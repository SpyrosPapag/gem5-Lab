#include <stdint.h>
#include <stdio.h>

int main(void) {
  uint32_t rs1 = 3, rs2 = 1,  res = 0;

  asm volatile(
        "minx %0, %1, %2"
        : "=r"(res)
        : "r"(rs1), "r"(rs2)
    );

  printf("Result = %u\n", res);

  return 0;
}
