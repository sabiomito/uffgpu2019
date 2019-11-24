#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace std;

__device__ void _2Dstencil_(int *d_e,int *d_r,float* c_coeff,int X,int Y,int k, int x, int y,int GX,int Gx,int Gy)
{     
    int h_e_i;
    int h_r_i = x + ( y * (X) );
    h_e_i = h_r_i;
    int temp = d_e[h_r_i];
    temp *= c_coeff[0];
    for(int lk =1;lk<(k/2)+1;lk++)
    {
        h_e_i = (x+lk) + ( (y) * (X) );
        temp += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x-lk) + ( (y) * (X) );
        temp += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x) + ( (y+lk) * (X) );
        temp += d_e[h_e_i]*c_coeff[lk];

        h_e_i = (x) + ( (y-lk) * (X) );
        temp += d_e[h_e_i]*c_coeff[lk];
    }
     h_r_i = Gx + ( (Gy) * (GX) );
    d_r[h_r_i] = temp;    
}
__global__ void _2Dstencil_global(int *d_e,int *d_r,float *c_coeff,int X,int Y,int k,int times){

    int x,y;//,h_e_i,h_r_i,Xs,Ys,Dx,Dy;
    x = threadIdx.x + (blockIdx.x*blockDim.x);
    y = threadIdx.y + (blockIdx.y*blockDim.y);
    int k2 = k/2*times;
    extern __shared__ int shared[];
    
    int blockThreadIndex = threadIdx.x + threadIdx.y*blockDim.x;
    // Xs = threadIdx.x;
    // Ys = threadIdx.y;
    int Dx = blockDim.x+(k*times);
    int Dy = blockDim.y+(k*times);
    int sharedTam = Dx*Dy;
    int * sharedRes = &shared[sharedTam];
    
    for(int stride=blockThreadIndex;stride<sharedTam;stride+=(blockDim.x*blockDim.y))
    {
        int globalIdx = (blockIdx.x*blockDim.x)-k2+stride%Dx + ((blockIdx.y*blockDim.y)-k2+stride/Dx)*X;
        if(globalIdx > 0 && (blockIdx.x*blockDim.x)-k2+stride%Dx < X && ((blockIdx.y*blockDim.y)-k2+stride/Dx)<Y)
            shared[stride] = d_e[globalIdx];
        else
            shared[stride] = 0;
       
    }
    __syncthreads();
    for(int t=times-1;t>0;t--)
    {  
        //_2Dstencil_(shared,sharedRes,c_coeff,Dx,Dy,k,threadIdx.x+k2,threadIdx.y+k2,Dx,threadIdx.x+k2,threadIdx.y+k2);
        int tDx = blockDim.x+(t*k);
        int tDy = blockDim.y+(t*k);
        int tk2 = (times-t)*k/2;
        // int tDx = blockDim.x+(1*k);
        // int tDy = blockDim.y+(1*k);
        // int tk2 = (1)*k/2;
        int tSharedTam = tDx * tDy;
        for(int stride=blockThreadIndex;stride<tSharedTam;stride+=(blockDim.x*blockDim.y))
        {
            _2Dstencil_(shared,sharedRes,c_coeff,Dx,Dy,k,(stride%tDx)+tk2,(stride/tDx)+tk2,Dx,(stride%tDx)+tk2,(stride/tDx)+tk2);
        }
        __syncthreads();
        for(int stride=blockThreadIndex;stride<sharedTam;stride+=(blockDim.x*blockDim.y))
        {
            shared[stride]=sharedRes[stride];
        }
        __syncthreads();
   }
   
    _2Dstencil_(shared,d_r,c_coeff,Dx,Dy,k,threadIdx.x+k2,threadIdx.y+k2,X,x,y);
   
    // for(int stride=blockThreadIndex;stride<sharedTam;stride+=(blockDim.x*blockDim.y))
    // {
    //     int globalIdx = (blockIdx.x*blockDim.x)-k2+stride%Dx + ((blockIdx.y*blockDim.y)-k2+stride/Dx)*X;
    //     if(globalIdx > 0 && (blockIdx.x*blockDim.x)-k2+stride%Dx < X && ((blockIdx.y*blockDim.y)-k2+stride/Dx)<Y)
    //     d_r[globalIdx] = sharedRes[stride];
       
    // }
        
}


int main(int argc, char* argv[]) {

int *h_e,*h_r;
int *d_e, *d_r;
int size,tam,sharedSize,sharedTam;
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
//sharedSize = ((block_dim.x+k)*(block_dim.y+k))*sizeof(int);
sharedSize = ((block_dim.x+(k*times))*(block_dim.y+(k*times)))*sizeof(int)*2;
//sharedTam = ((block_dim.x+(k*2))*(block_dim.y+(k*2)));
size = X * Y * sizeof(int);
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
_2Dstencil_global<<<grid_dim,block_dim,sharedSize>>>(d_e,d_r,d_c_coeff,X,Y,k,times);

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



/*
for(int lk = 1;lk<(k/2)+1;lk++)
    {
        if(x+lk < X)
        {
            if((x+lk)/Dx == blockIdx.x)
            {
                h_e_i = ((x+lk)%Dx) + ( (Ys) * (Dx) );
                temp += shared[h_e_i]*c_coeff[lk];
            }else
            {
                h_e_i = (x+lk) + ( (y) * (X) );
                temp += d_e[h_e_i]*c_coeff[lk];
            }
            
        }
        if(x-lk >= 0)
        {
            if((x-lk)/Dx == blockIdx.x)
            {
                h_e_i = ((x-lk)%Dx) + ( (Ys) * (Dx) );
                temp += shared[h_e_i]*c_coeff[lk];
            }
            else
            {
                h_e_i = (x-lk) + ( (y) * (X) );
                temp += d_e[h_e_i]*c_coeff[lk];
            }
               
        }
        if(y+lk < Y)
        {
            if((y+lk)/Dy == blockIdx.y)
            {
                h_e_i = ((Xs) + ( ((y+lk)%Dy) * (Dx) ));
                temp += shared[h_e_i]*c_coeff[lk];
            }
            else
            {
                h_e_i = (x) + ( (y+lk) * (X) );
                temp += d_e[h_e_i]*c_coeff[lk];
            }
        }
        if(y-lk >= 0)
        {
            if((y-lk)/Dy == blockIdx.y)
            {
                h_e_i = ((Xs) + ( ((y-lk)%Dy) * (Dx) ));
                temp += shared[h_e_i]*c_coeff[lk];
            }
            else
            {
                h_e_i = (x) + ( (y-lk) * (X) );
                temp += d_e[h_e_i]*c_coeff[lk];
            }
        }
    }
    d_r[h_r_i] = temp;  
*/