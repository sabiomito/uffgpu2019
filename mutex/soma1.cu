#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

__global__ void soma1(int x[],int hist[], int n, int blks) {

    int thread_id = threadIdx.x + blockIdx.x * blockDim.x;

    while(thread_id < n){

        int index = x[thread_id];
        //atomicAdd(&hist[x[thread_id]],1);
        hist[x[thread_id]]++;
        thread_id+=blks*blockDim.x;
    }

}
/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*3 - n_blocos
*4 - print
*/
int main(int argc, char* argv[]) {
    int n, th_p_blk;
    int *h_x;
    int *d_x;
    int * d_hist,* h_hist,* h_hist_res;
    size_t size,size_hist;
    int range = 10;

    int print = 0;
    th_p_blk = 1024;
    n = 1024;

  if(argc > 1)
      n = atoi(argv[1]);

    if(argc > 2)
      th_p_blk = atoi(argv[2]);


    int blks = ceil((float)n/(float)th_p_blk);

    if(argc > 3)
      blks = atoi(argv[3]);

    if(argc > 4)
    print=atoi(argv[4]);


    size = n*sizeof(int);
    size_hist = n*sizeof(int);

    // Allocate memory for the vectors on host memory.
    h_x = (int*) malloc(size);
    h_hist_res = (int*) malloc(size_hist);
    h_hist = (int*) malloc(size_hist);


    for (int i = 0; i < range; i++) {
        h_hist[i] = 0;
        h_hist_res[i] = 0;
    }
    for (int i = 0; i < n; i++) {
        h_x[i] = (int)rand()%range;
        h_hist_res[h_x[i]]+=1;
    }



    /* Allocate vectors in device memory */
    cudaMalloc(&d_x, size);
    cudaMalloc(&d_hist, size_hist);

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_hist, h_hist, size_hist, cudaMemcpyHostToDevice);


    clock_t Ticks[2];
    Ticks[0] = clock();

    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…

    /* Kernel Call */
    soma1<<<blks,th_p_blk>>>(d_x,d_hist, n,blks);


    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    //printf ("Total GPU Time: %.5f ms \n", elapsedTime);
    printf ("[%d,%.5f],\n", n,elapsedTime);
    cudaEventDestroy(start);

    cudaThreadSynchronize();
    cudaMemcpy(h_hist, d_hist, size, cudaMemcpyDeviceToHost);


    bool certo=true;
for (int i = 0; i < range; i++){
        if(h_hist[i] != h_hist_res[i])
          certo=false;
    }

       // printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");



    /* Free device memory */
    cudaFree(d_x);
    cudaFree(d_hist);
    /* Free host memory */
    free(h_x);
    free(h_hist);
    free(h_hist_res);

    return 0;
} /* main */

