#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

using namespace std;
#define TYPE float

__global__ void fwd_3D_16x16_order8( TYPE *g_input, TYPE *g_output, TYPE *g_vsq, /* output initially contains (t-2) step*/const int dimx, const int dimy, const int dimz)
{
#define BDIMX 16 // tile (and threadblock) size in x
#define BDIMY 16 // tile (and threadblock) size in y
#define radius 4 // half of the order in space (k/2)
float c_coeff[5] = {1.0 , 0.8 , 0.6 , 0.4, 0.2};
__shared__ float s_data[BDIMY+2*radius][BDIMX+2*radius];
int ix = blockIdx.x*blockDim.x + threadIdx.x;
int iy = blockIdx.y*blockDim.y + threadIdx.y;
int in_idx = iy*dimx + ix; // index for reading input
int out_idx = 0; // index for writing output
int stride = dimx*dimy; // distance between 2D slices (in elements)
float infront1, infront2, infront3, infront4; // variables for input “in front of” the current slice
float behind1, behind2, behind3, behind4; // variables for input “behind” the current slice
float current; // input value in the current slice
int tx = threadIdx.x + radius; // thread’s x-index into corresponding shared memory tile (adjusted for halos)
int ty = threadIdx.y + radius; // thread’s y-index into corresponding shared memory tile (adjusted for halos)
// fill the "in-front" and "behind" data
behind3 = g_input[in_idx]; in_idx += stride;
behind2 = g_input[in_idx]; in_idx += stride;
behind1 = g_input[in_idx]; in_idx += stride;
current = g_input[in_idx]; out_idx = in_idx; in_idx += stride;
infront1 = g_input[in_idx]; in_idx += stride;
infront2 = g_input[in_idx]; in_idx += stride;
infront3 = g_input[in_idx]; in_idx += stride;
infront4 = g_input[in_idx]; in_idx += stride;
for(int i=radius; i<dimz-radius; i++)
{
//////////////////////////////////////////
// advance the slice (move the thread-front)
 behind4 = behind3;
 behind3 = behind2;
 behind2 = behind1;
 behind1 = current;
 current = infront1;
 infront1 = infront2;
 infront2 = infront3;
 infront3 = infront4;
 infront4 = g_input[in_idx];
 in_idx += stride;
 out_idx += stride;
 __syncthreads();
/////////////////////////////////////////
// update the data slice in smem
if(threadIdx.y<radius) // halo above/below
 {
 s_data[threadIdx.y][tx] = g_input[out_idx-radius*dimx];
 s_data[threadIdx.y+BDIMY+radius][tx] = g_input[out_idx+BDIMY*dimx];
 }
if(threadIdx.x<radius) // halo left/right
 {
 s_data[ty][threadIdx.x] = g_input[out_idx-radius];
 s_data[ty][threadIdx.x+BDIMX+radius] = g_input[out_idx+BDIMX];
 }
// update the slice in smem
 s_data[ty][tx] = current;
 __syncthreads();
/////////////////////////////////////////
// compute the output value
 float temp = 2.f*current - g_output[out_idx];
 float div = c_coeff[0] * current; //c_coefff deveria ser um array do tamanho do radius
 div += c_coeff[1]*( infront1 + behind1
 + s_data[ty-1][tx] + s_data[ty+1][tx] + s_data[ty][tx-1] + s_data[ty][tx+1] );
 div += c_coeff[2]*( infront2 + behind2 + s_data[ty-2][tx] + s_data[ty+2][tx] + s_data[ty][tx-2] + s_data[ty][tx+2] );
 div += c_coeff[3]*( infront3 + behind3 + s_data[ty-3][tx] + s_data[ty+3][tx] + s_data[ty][tx-3] + s_data[ty][tx+3] );
 div += c_coeff[4]*( infront4 + behind4 + s_data[ty-4][tx] + s_data[ty+4][tx] + s_data[ty][tx-4] + s_data[ty][tx+4] );
 g_output[out_idx] = temp + div*g_vsq[out_idx];
}
}
//Tamanho do radius não é variável
//A entrada de dados ja vem com as bordas aumentadas

/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*3 - n_blocos
*4 - print
*/
int main(int argc, char* argv[]) {

    float *h_e,*h_r,*h_r_test,*h_g_vsq;
    float *d_e, *d_r,*d_g_vsq;
    int size,tam,times;
    clock_t Ticks[2];

    

    

    times = 1;
    int X=8;
    int Y=8;
    int BX=8;
    int BY=8;
    int Z=4;
    int k=2;
    int GX=1;
    int GY=1;

    if(argc > 1)
    {
        X = atoi(argv[1]);
        BX=X;
    }
      
    if(argc > 2)
    {
        Y = atoi(argv[2]);
        BY = Y;
    }
      
    if(argc > 3)
      Z = atoi(argv[3]);
    if(argc > 4)
      k = atoi(argv[4]);

    if(X>32)
    {
        GX = ceil((float)X/(float)32);
        BX = 32;
    }
    if(Y>32)
    {
        GY = ceil((float)Y/(float)32);
        BY = 32;
    }
    
    
    dim3 block_dim(BX,BY,1);
    dim3 grid_dim(GX,GY,1);

    //sharedSize = block_dim.x*block_dim.y*sizeof(float);
    size = X * Y * Z * sizeof(float);
    tam = X * Y * Z;


    h_e = (float*) malloc(size);
    h_r = (float*) malloc(size);
    h_r_test = (float*) malloc(size);
    h_g_vsq = (float*) malloc(size);
    cudaMalloc(&d_e, size);
    cudaMalloc(&d_r, size);
    cudaMalloc(&d_g_vsq, size);


    for (int i = 0; i < tam; i++) {
        h_g_vsq[i] = (float)(rand()%100)/100.0;
        h_e[i] = (float)(rand()%9000)/100.0;
        h_r[i] = 0;
    }

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_g_vsq, h_g_vsq, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_e, h_e, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_r, h_r, size, cudaMemcpyHostToDevice);



    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); 

    /******************
    *** Kernel Call ***
    *******************/
    //_3Dstencil_global<<<blks,th_p_blk>>>(d_e,d_r,X,Y,Z);
    //_3Dstencil_sharedMemory<<<grid_dim,block_dim,sharedSize>>>(d_e,d_r,X,Y,Z,k);
    fwd_3D_16x16_order8<<<grid_dim,block_dim>>>(d_e,d_r,d_g_vsq, X,Y,Z);
    cudaError_t err = cudaSuccess;
    err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch _3Dstencil_global kernel (error code %s)!\n", cudaGetErrorString(err));
    }
    /******************
    *** Kernel Call ***
    *******************/



    cudaDeviceSynchronize();
    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    
    Ticks[1] = clock();
    double Tempo = (Ticks[1] - Ticks[0]) * 1000.0 / CLOCKS_PER_SEC;
    printf("X %d || Y %d \nBX %d || BY %d\nGX %d || GY %d\nZ %d \n",X,Y,BX,BY,GX,GY,Z);
    printf ("[%d,%.5f,%.5f],\n", tam,elapsedTime,Tempo/1000.0);
 
    cudaMemcpy(h_r, d_r, size, cudaMemcpyDeviceToHost);

    
    cudaFree(d_e);
    cudaFree(d_r);
    std::free(h_e);
    std::free(h_r);
    std::free(h_r_test);

    return 0;
} /* main */

