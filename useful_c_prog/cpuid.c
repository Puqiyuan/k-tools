#include <stdio.h>

typedef unsigned int u32;
void cpuid_count(u32 id, u32 count, u32 *a, u32 *b, u32 *c, u32 *d)
{
	asm volatile("cpuid"
		     : "=a" (*a), "=b" (*b), "=c" (*c), "=d" (*d)
		     : "0" (id), "2" (count)
	);
}

#define cpuid(id, a, b, c, d) cpuid_count(id, 0, a, b, c, d)

static inline unsigned int cpuid_eax(unsigned int op)
{
	unsigned int eax, ebx, ecx, edx;

	cpuid(op, &eax, &ebx, &ecx, &edx);

	return eax;
}

int main(int argc, char *argv[])
{
	u32 eax = cpuid_eax(0x80000000);
	u32 ebx, ecx, edx;

	printf("eax: %x\n", eax);
	if (eax >= 0x80000007) {
		cpuid(0x80000007, &eax, &ebx, &ecx, &edx);
		printf("edx: %x\n", edx);
		if (edx & (1 << 8))
			printf("invariant TSC available\n");
	}
	return 0;
}
