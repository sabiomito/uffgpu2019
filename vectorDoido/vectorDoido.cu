/* File:     vec_add.cu
 * Purpose:  Implement vector addition on a gpu using cuda
 *
 * Compile:  nvcc [-g] [-G] -o vec_add vec_add.cu
 * Run:      ./vec_add
 */

#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

__global__ void Vec_add(float x[], float y[], float z[], int n, int blks) {
    int thread_id = threadIdx.x + blockIdx.x * blockDim.x;
    while(thread_id < n){
        z[thread_id] = x[thread_id] + y[thread_id];
        thread_id+=blks*blockDim.x;
    }
}


int main(int argc, char* argv[]) {
    int n, th_p_blk;
    float *h_x, *h_y, *h_z, *h_z_res;
    float *d_x, *d_y, *d_z;
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

    /* Define vector length */

    size = n*sizeof(float);

    // Allocate memory for the vectors on host memory.
    h_x = (float*) malloc(size);
    h_y = (float*) malloc(size);
    h_z = (float*) malloc(size);
    h_z_res = (float*) malloc(size);

    for (int i = 0; i < n; i++) {
        h_x[i] = rand();
        h_y[i] = rand();
        h_z_res[i] = h_x[i]+h_y[i];
    }


    /* Allocate vectors in device memory */
    cudaMalloc(&d_x, size);
    cudaMalloc(&d_y, size);
    cudaMalloc(&d_z, size);

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, size, cudaMemcpyHostToDevice);
    

    clock_t Ticks[2];
    Ticks[0] = clock();
    /* Kernel Call */
    Vec_add<<<blks,th_p_blk>>>(d_x, d_y, d_z, n,blks);


    Ticks[1] = clock();
    double Tempo = (Ticks[1] - Ticks[0]) * 1000.0 / CLOCKS_PER_SEC;
    printf("\n\n Tempo gasto: %g ms para:\n %d elementos \n %d blocks \n %d th_p_blk \n\n", Tempo,n,blks,th_p_blk);


    cudaThreadSynchronize();
    cudaMemcpy(h_z, d_z, size, cudaMemcpyDeviceToHost);


    bool certo=true;
    for (int i = 0; i < n; i++){
        if(h_z_res[i] != h_z[i])
          certo=false;
    }
    printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");
   


    /* Free device memory */
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
    /* Free host memory */
    free(h_x);
    free(h_y);
    free(h_z);
    free(h_z_res);

    return 0;
} /* main */
