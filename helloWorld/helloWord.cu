#include <stdio.h>
#include <cuda_runtime.h>

__global__ void mykernel(void){
printf("Oi GPU\n");
}

int main(void)
{
int *a,*b,*c;
int *d_a,*d_b,*d_c;

cudaMalloc((void)


mykernel<<<2,5>>>();
cudaDeviceSynchronize();
printf("Hello World !!\n");
return 0;
}
