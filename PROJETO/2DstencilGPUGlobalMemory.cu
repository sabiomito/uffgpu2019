#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace std;

__global__ void _copy_dr_to_de(int *d_e,int *d_r,int X,int Y){
    int x,y;
    x = threadIdx.x + (blockIdx.x*blockDim.x);
    y = threadIdx.y + (blockIdx.y*blockDim.y);
    int h_r_i = x + ( y * (X) );
    d_e[h_r_i] = d_r[h_r_i];
}
__global__ void _2Dstencil_global(int *d_e,int *d_r,float *c_coeff,int X,int Y,int k){

    int x,y;
    x = threadIdx.x + (blockIdx.x*blockDim.x);
    y = threadIdx.y + (blockIdx.y*blockDim.y);
    int h_r_i = x + ( y * (X) );
    int h_e_i = h_r_i;
    d_r[h_r_i] = d_e[h_e_i];
    for(int lk = 1;lk<(k/2)+1;lk++)
    {
        if(x+lk >= X)
            h_e_i = (x-lk) + ( (y) * (X) );
        else
            h_e_i = (x+lk) + ( (y) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk-1];

        if(x-lk < 0)
            h_e_i = (x+lk) + ( (y) * (X) );
        else
            h_e_i = (x-lk) + ( (y) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk-1];


        if(y+lk >= Y)
            h_e_i = (x) + ( (y-lk) * (X) );
        else
            h_e_i = (x) + ( (y+lk) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk-1];

        if(y-lk < 0)
            h_e_i = (x) + ( (y+lk) * (X) );
        else
            h_e_i = (x) + ( (y-lk) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk-1];

    }  


}


int main(int argc, char* argv[]) {

int *h_e,*h_r;
int *d_e, *d_r;
int size,tam;
int X=32;
int Y=32;
int k=4;
int times = 1;
int BX=32;
int BY=32;
int GX=1;
int GY=1;
float *c_coeff,*d_c_coeff;
if(argc > 1)
{
    X = atoi(argv[1]);
    Y = X;
}
if(argc > 2)
{
    k = atoi(argv[2]);
}

if(argc > 3)
{
    times = atoi(argv[3]);
}


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

size = X * Y * sizeof(int);
tam = X * Y;


h_e = (int*) malloc(size);
h_r = (int*) malloc(size);
c_coeff = (float*)malloc((k/2+1)*sizeof(float));
cudaMalloc(&d_e, size);
cudaMalloc(&d_r, size);
cudaMalloc(&d_c_coeff,(k/2+1)*sizeof(float));

for(int i=0;i<(k/2+1);i++)
    c_coeff[(k/2+1)-i-1]=(float)i/(float)(k/2+1);


FILE *arq;
arq = fopen("entrada.txt", "rt");
for(int i=0;i<X;i++)
    for(int j=0;j<Y;j++)
        fscanf(arq," %d",&h_e[i+j*X]);
fclose(arq);


/* Copy vectors from host memory to device memory */
cudaMemcpy(d_e, h_e, size, cudaMemcpyHostToDevice);
cudaMemcpy(d_c_coeff, c_coeff, (k/2+1)*sizeof(float), cudaMemcpyHostToDevice);


cudaEvent_t start, stop;
cudaEventCreate (&start);
cudaEventCreate (&stop);
cudaEventRecord (start, 0); 

/******************
*** Kernel Call ***
*******************/
//_3Dstencil_global<<<blks,th_p_blk>>>(d_e,d_r,X,Y,Z);
for(int t=0;t<times;t++)
{
_2Dstencil_global<<<grid_dim,block_dim>>>(d_e,d_r,d_c_coeff,X,Y,k);
_copy_dr_to_de<<<grid_dim,block_dim>>>(d_e,d_r,X,Y);
}
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


    printf("X %d || Y %d \nBX %d || BY %d \n",X,Y,BX,BY);
    printf ("[%d,%.5f],\n", tam,elapsedTime);
 
    cudaMemcpy(h_r, d_r, size, cudaMemcpyDeviceToHost);

    
arq = fopen("resultado.txt", "wt");
for(int i=0;i<X;i++)
{
    for(int j=0;j<Y;j++)
    {
      fprintf(arq," %d",h_r[i+j*X]);
    }
    fprintf(arq,"\n");
}
fclose(arq);


    cudaFree(d_e);
    cudaFree(d_r);
    cudaFree(d_c_coeff);
    std::free(h_e);
    std::free(h_r);
    std::free(c_coeff);

    return 0;
} /* main */

