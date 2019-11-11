#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace std;

__device__ void _3Dstencil_(float *d_e,float *d_r,int X,int Y,int Z,int k, int x, int y,int z)
{     
    int h_r_i = x + ( y * (X) ) + ( z* (X*Y) );
    int h_e_i = h_r_i;
    d_r[h_r_i] = d_e[h_e_i];
    for(int lk =0;lk<(k/2);lk++)
    {
        h_e_i = (x+lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];

        h_e_i = (x-lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];

        h_e_i = (x) + ( (y+lk) * (X) ) + ( (z) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];

        h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];


        h_e_i = (x) + ( (y) * (X) ) + ( (z+lk) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];

        h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
        d_r[h_r_i] += d_e[h_e_i];
    }  
}
__global__ void _3Dstencil_SharedMemory_Cube(float *d_e,float *d_r,int X,int Y,int Z,int k,int t)
{
    int x,y,globalidx,localIdx;
    x = threadIdx.x + (blockIdx.x*blockDim.x);
    y = threadIdx.y + (blockIdx.y*blockDim.y);
    int k2=k/2;

    //conta para tamanho do cubo em cada dimensão DIM+t*k2

    extern __shared__ float cube[];
    for(int z=0;z<Z;z++)
    {
        globalidx = x + y*X + z*(X*Y);
        localIdx = threadIdx.x + threadIdx.y*blockDim.x + z*(blockDim.x*blockDim.y);
        cube[localIdx] = d_e[globalidx];
    }
    for(int z=k2;z<Z-k2;z++)
    {
        _3Dstencil_(d_e,d_r,X,Y,Z,k,x+k2,y+k2,z);
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

    float *h_e,*h_r,*h_r_test;
    float *d_e, *d_r;
    int size,tam,times,sharedSize;
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

    sharedSize = ((block_dim.x+k)*(block_dim.y+k)*(Z+k))*sizeof(float);
    size = (X+k) * (Y+k) * (Z+k) * sizeof(float);
    tam = X * Y * Z;

    X=X+k;
    Y=Y+k;
    Z=Z+k;


    h_e = (float*) malloc(size);
    h_r = (float*) malloc(size);
    h_r_test = (float*) malloc(size);
    cudaMalloc(&d_e, size);
    cudaMalloc(&d_r, size);


    for (int i = 0; i < size/sizeof(float); i++) {
        h_e[i] = (float)(rand()%9000)/100.0;
        h_r[i] = 0;
    }

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_e, h_e, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_r, h_r, size, cudaMemcpyHostToDevice);
    int k2 = k/2;
    for(int t =0; t<times; t++)
    {

        for(int z=k2;  z<Z-k2;  z++)
        {
        
            for(int y=k2;  y<Y-k2;  y++)
            {
                for(int x=k2;  x<X-k2;  x++)
                {
                    
                    
                    int h_r_i = x + ( y * (X) ) + ( z* (X*Y) );
                        
                    int h_e_i = h_r_i;
                    h_r_test[h_r_i] = h_e[h_e_i];
                    for(int lk =0;lk<(k/2);lk++)
                        {
                            

                            
                            if(x+lk >= X)
                                h_e_i = (x-lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                            else
                                h_e_i = (x+lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];

                            if(x-lk < 0)
                                h_e_i = (x+lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                            else
                                h_e_i = (x-lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];


                            if(y+lk >= Y)
                                h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                            else
                                h_e_i = (x) + ( (y+lk) * (X) ) + ( (z) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];

                            if(y-lk < 0)
                                h_e_i = (x) + ( (y+lk) * (X) ) + ( (z) * (X*Y) );
                            else
                                h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];


                            if(z+lk >= Z)
                                h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                            else
                                h_e_i = (x) + ( (y) * (X) ) + ( (z+lk) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];

                            if(z-lk < 0)
                                h_e_i = (x) + ( (y) * (X) ) + ( (z+lk) * (X*Y) );
                            else
                                h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                            h_r_test[h_r_i] += h_e[h_e_i];

                        }  
                }
            }
            
        }

        for (int i = 0; i < tam; i++) 
        {
            h_e[i] = h_r_test[i];
        }

    }


    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); 

    /******************
    *** Kernel Call ***
    *******************/
    //_3Dstencil_global<<<blks,th_p_blk>>>(d_e,d_r,X,Y,Z);
    _3Dstencil_SharedMemory_Cube<<<grid_dim,block_dim,sharedSize>>>(d_e,d_r,X,Y,Z,k,times);

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
    printf("X %d || Y %d \nBX %d || BY %d\nZ %d \n",X,Y,BX,BY,Z);
    printf ("[%d,%.5f,%lf],\n", tam,elapsedTime,Tempo/1000.0);
 
    cudaMemcpy(h_r, d_r, size, cudaMemcpyDeviceToHost);

    bool certo=true;
    //printf("threads/blk %d -- blocks %d\n",th_p_blk,blks);
    for (int i = 0; i < tam; i++){
        //printf("%d - %d\n",h_z_res[i],h_z[i]);
        if(h_r_test[i] != h_r[i])
          certo=false;
    }
    if(!certo)
    printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");

    cudaFree(d_e);
    cudaFree(d_r);
    std::free(h_e);
    std::free(h_r);
    std::free(h_r_test);

    return 0;
} /* main */

