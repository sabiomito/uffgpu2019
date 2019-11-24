#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace std;

__global__ void _copy_dr_to_de(int *d_e,int *d_r,int X,int Y,int k2){
    int x,y;
    x = threadIdx.x + (blockIdx.x*blockDim.x)+k2;
    y = threadIdx.y + (blockIdx.y*blockDim.y)+k2;
    int h_r_i = x + ( y * (X) );
    if(x<X && y<Y)
    d_e[h_r_i] = d_r[h_r_i];
}
__global__ void _2Dstencil_global(int *d_e,int *d_r,float *c_coeff,int X,int Y,int k){

    int x,y;
    int k2=k/2;
    x = threadIdx.x + (blockIdx.x*blockDim.x);
    y = threadIdx.y + (blockIdx.y*blockDim.y);

    x+=k2;
    y+=k2;
    int h_r_i = x + ( y * (X) );
    int h_e_i = h_r_i;
    d_r[h_r_i] = d_e[h_e_i]*c_coeff[0];
    for(int lk =1;lk<(k/2)+1;lk++)
    {
        h_e_i = (x+lk) + ( (y) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x-lk) + ( (y) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x) + ( (y+lk) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x) + ( (y-lk) * (X) );
        d_r[h_r_i] += d_e[h_e_i]*c_coeff[lk];
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
    
int k2=k/2;
dim3 block_dim(BX,BY,1);
dim3 grid_dim(GX,GY,1);

size = (X+k) * (Y+k) * sizeof(int);
tam = X * Y;



h_e = (int*) malloc(size);
h_r = (int*) malloc(size);
c_coeff = (float*)malloc((k/2+1)*sizeof(float));
cudaMalloc(&d_e, size);
cudaMalloc(&d_r, size);
cudaMalloc(&d_c_coeff,(k/2+1)*sizeof(float));

printf("\n coefs \n");
for(int i=0;i<(k/2+1);i++)
{
    c_coeff[i]=(float)((k/2+1)-i)/(float)(k/2+1);
   
}
for(int i=0;i<(k/2+1);i++)
{
    printf(" %f",c_coeff[i]);
}
printf("\n coefs \n");


FILE *arq;
arq = fopen("entrada.txt", "rt");
for(int i=k2;i<(X+k2);i++)
    for(int j=k2;j<(Y+k2);j++)
        fscanf(arq," %d",&h_e[i+j*(X+k)]);
fclose(arq);

for(int i=k2;i<(X+k2);i++)
    for(int j=1;j<k2+1;j++)
    {
        h_e[i+(k2-j)*(X+k)] = h_e[i+(k2+j-1)*(X+k)];
        h_e[i+(Y+k2+j-1)*(X+k)] =  h_e[i+(Y+k2-j)*(X+k)] ;
    }

for(int i=1;i<k2+1;i++)
    for(int j=k2;j<(X+k2);j++)
    {
        h_e[(k2-i)+(j)*(X+k)] = h_e[(k2+i-1)+(j)*(X+k)];
        h_e[(X+k2+i-1)+(j)*(X+k)] =  h_e[(X+k2-i)+(j)*(X+k)];
    }

       
        

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
_2Dstencil_global<<<grid_dim,block_dim>>>(d_e,d_r,d_c_coeff,X+k,Y+k,k);
_copy_dr_to_de<<<grid_dim,block_dim>>>(d_e,d_r,X+k,Y+k,k/2);
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
for(int i=k2;i<X+k2;i++)
{
    for(int j=k2;j<Y+k2;j++)
    {
      fprintf(arq," %d",h_r[i+j*(X+k)]);
    }
    fprintf(arq,"\n");
}
fclose(arq);

// arq = fopen("resultado.txt", "wt");
// for(int i=0;i<X+k;i++)
// {
//     for(int j=0;j<Y+k;j++)
//     {
//       fprintf(arq," %d",h_e[i+j*(X+k)]);
//     }
//     fprintf(arq,"\n");
// }
// fclose(arq);


    cudaFree(d_e);
    cudaFree(d_r);
    cudaFree(d_c_coeff);
    std::free(h_e);
    std::free(h_r);
    std::free(c_coeff);

    return 0;
} /* main */

