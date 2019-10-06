#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

__global__ void shared_mem(int x[], int n, int blks) {

  int thread_id = threadIdx.x + blockIdx.x * blockDim.x;
  __shared__ float temp_data;
  
  while(thread_id < n){
    temp_data = x[thread_id];
    for(int i=0;i<n;i++){
      temp_data+=1;
    }
    thread_id+=blks*blockDim.x;
  }

}

__global__ void global_mem(int x[], int n, int blks) {

  int thread_id = threadIdx.x + blockIdx.x * blockDim.x;
  while(thread_id < n){
    for(int i=0;i<n;i++){
        x[thread_id]+=1;
    }
    thread_id+=blks*blockDim.x;
  }
}
/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*3 - n_blocos
*/
int main(int argc, char* argv[]) {
    int n, th_p_blk;
    int *h_x;
    int *d_x;
    size_t size;

    th_p_blk = 1024;
    n = 1024;

  if(argc > 1)
      n = atoi(argv[1]);

    if(argc > 2)
      th_p_blk = atoi(argv[2]);


    int blks = ceil((float)n/(float)th_p_blk);

    if(argc > 3)
      blks = atoi(argv[3]);



    size = n*sizeof(int);

    // Allocate memory for the vectors on host memory.
    h_x = (int*) malloc(size);

    for (int i = 0; i < n; i++) {
        h_x[i] =0;
    }



    /* Allocate vectors in device memory */
    cudaMalloc(&d_x, size);

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);


    float time_shared,time_global;
    cudaEvent_t start, stop;

    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…

    /* Kernel Call */
    shared_mem<<<blks,th_p_blk>>>(d_x, n,blks);
    cudaThreadSynchronize();

    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    time_shared = elapsedTime;


    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…

    /* Kernel Call */
    global_mem<<<blks,th_p_blk>>>(d_x, n,blks);
    cudaThreadSynchronize();

    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);

    cudaEventElapsedTime (&elapsedTime, start, stop);
    time_global = elapsedTime;
    //printf ("Total GPU Time: %.5f ms \n", elapsedTime);
    printf ("[%d,%.5f,%.5f],\n", n,time_shared,time_global);
    cudaEventDestroy(start);



    /* Free device memory */
    cudaFree(d_x);
    /* Free host memory */
    free(h_x);

    return 0;
} /* main */

