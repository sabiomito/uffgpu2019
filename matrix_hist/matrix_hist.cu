
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

__global__ void Mat_hist(int x[], int z[], int n) {


    int thread_id = threadIdx.x + blockIdx.x * blockDim.x;
    
    __shared__ int hist[256];

    if(threadIdx.x < 256)
    hist[threadIdx.x]=0;
    __syncthreads();
    if(thread_id<n)
    {
        atomicAdd(&hist[x[thread_id]],1);
    }
    __syncthreads();
    if(threadIdx.x < 256)
        atomicAdd(&z[threadIdx.x],hist[threadIdx.x]);	
}
/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*/
int main(int argc, char* argv[]) {
    int n, th_p_blk;
    int *h_x, *h_z, *h_z_res;
    int *d_x, *d_z;
    size_t size,size_hist;


    th_p_blk = 1024;
    n = 32;
    
    if(argc > 1)
      n = atoi(argv[1]);
    if(argc > 2)
      th_p_blk = atoi(argv[2]);


    int blks = ceil((float)(n)/(float)th_p_blk);

    /* Define vector length */

    size = n*sizeof(int);
    size_hist = 256*sizeof(int);

    // Allocate memory for the vectors on host memory.
    h_x = (int*) malloc(size);
    h_z = (int*) malloc(size_hist);
    h_z_res = (int*) malloc(size_hist);

    for (int i = 0; i < 256; i++)
    {
        h_z_res[i] = 0;
        h_z[i] = 0;
    }
        

    for (int i = 0; i < n; i++) {
        h_x[i] = (int)rand()%256;
        h_z_res[h_x[i]]++;
    }

    
    
   

    /* Allocate vectors in device memory */
    cudaMalloc(&d_x, size);
    cudaMalloc(&d_z, size_hist);

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_z, h_z, size_hist, cudaMemcpyHostToDevice);
    



    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…

    /* Kernel Call */
    Mat_hist<<<blks,th_p_blk>>>(d_x, d_z, n);

    cudaThreadSynchronize();
    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    printf ("[%d,%.5f],\n", n,elapsedTime);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

 
    cudaMemcpy(h_z, d_z, size_hist, cudaMemcpyDeviceToHost);


    bool certo=true;
    //printf("threads/blk %d -- blocks %d\n",th_p_blk,blks);
    for (int i = 0; i < 256; i++){
        //printf("%d - %d\n",h_z_res[i],h_z[i]);
        if(h_z_res[i] != h_z[i])
          certo=false;
    }

    if(!certo)
    printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");


    /* Free device memory */
    cudaFree(d_x);
    cudaFree(d_z);
    /* Free host memory */
    free(h_x);
    free(h_z);
    free(h_z_res);

    return 0;
} /* main */

