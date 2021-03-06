#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

/*
Instruções
COMPILAR -->  nvcc 2DstencilGPUSharedMemoryBlankBorderTimeSpaceSharingOpencvKarma.cu -o go `pkg-config --cflags --libs opencv` -w
EXECUTAR --> ./go DOMAIN_DIMS STENCIL_ORDER SPACE_TIME_BLOCK_TIMES BLOCK_DIM_X BLOCK_DIM_Y
*/

//////////////////////////////////////////////////////////////////////////
static void HandleError( cudaError_t err,
    const char *file,
    int line ) {
if (err != cudaSuccess) {
printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
file, line );
exit( EXIT_FAILURE );
}
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
//////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <opencv2/imgcodecs.hpp>
#include <math.h>
#include <string>

using namespace std;

//===> CONSTANTES karma model <===//
#ifndef MODEL_WIDTH
#define MODEL_WIDTH 0
#endif
#define Eh 3.0f
#define En 1.0f
#define Re 0.6f
#define tauE 5.0f
#define tauN 250.0f
#define gam 0.001f
#define East 1.5415f
#define DT 0.05f
#define DX (12.0f / MODEL_WIDTH)

/*
Função somente da GPU que recebe os parametros para o calculo de um stencil
d_e - dado de entrada
d_r - dado de saida
d_v - campo que deve ser atualizado
c_coeff - variável utilizada para armazenar o valores dos coeficcientes do stencil (utilizada apenas na versão com stencil simples usado anteriormente)
X - Y - Dimensões das estruturas de entrada
k - ordem do stencil
x -y - posição do centro do stencil na estrutura de entrada
GX - Dimensão horizontal da estrutura do dado de saída
Gx - Gy posição do centro do stencil na estrutura de saida
*/
__device__ void destinyTest(float *d_r,int GX, int Gx, int Gy,float val)
{
    d_r[Gx + ((Gy) * (GX))] = val;
}
__device__ void _2Dstencil_(float *d_e, float *d_r, float *d_v, int X, int x, int y, int GX, int Gx, int Gy)
{
    int h_e_i = x + (y * (X));
    float temp = d_e[h_e_i];
    
    float rv = d_v[h_e_i];


    float Rn = (1.0f / (1.0f - expf(-Re))) - rv;
    float p = (temp > En) * 1.0f;
    float dv = (Rn * p - (1.0f - p) * rv) / tauN;
    float Dn = rv * rv;
    float hE = (1.0f - tanh(temp - Eh)) * temp * temp / 2.0f;
    float du = (((East - Dn) * hE) - temp) / tauE;

    float xlapr = d_e[(x + 1) + ((y) * (X))] - temp;
    float xlapl = temp - d_e[(x - 1) + ((y) * (X))];
    float xlapf = d_e[(x) + ((y + 1) * (X))] - temp;
    float xlapb = temp - d_e[(x) + ((y - 1) * (X))];

    float lap = xlapr - xlapl + xlapf - xlapb;

   
    temp = (temp + (du * DT) + (lap * DT * gam / (DX * DX)));


    d_v[h_e_i] = rv + dv * DT;
    //d_v[h_e_i] = rv+rv;
    h_e_i = Gx + ((Gy) * (GX));
    d_r[h_e_i] = temp;//d_v[h_e_i];// d_e[h_e_i]+1;// = temp;
   // d_r[h_e_i] = rv;
    

}
/*
função chamada pelo host que controla as cópias e a ordem do calculo dos stencils bem como a carga para cada thread
*/
__global__ void _2Dstencil_global(float *d_e, float *d_r, float *d_v, int X, int Y, int times,bool eraseMiddle)
{

    int x, y; //,h_e_i,h_r_i,Xs,Ys,Dx,Dy;
    x = threadIdx.x + (blockIdx.x * blockDim.x);
    y = threadIdx.y + (blockIdx.y * blockDim.y);
    extern __shared__ float sharedOrig[];

    int blockThreadIndex = threadIdx.x + threadIdx.y * blockDim.x;
    // Xs = threadIdx.x;
    // Ys = threadIdx.y;
    int Dx = blockDim.x + (2 * times);
    int Dy = blockDim.y + (2 * times);
    int sharedTam = Dx * Dy;

    float * shared = sharedOrig;
    float * sharedRes = shared + sharedTam;
    float * sharedV = sharedRes + sharedTam; 

    //float * sharedRes = &shared[sharedTam];
    //float *sharedV = &sharedRes[sharedTam];

    /*
    Copia o Tile de memória compartilhada necessária para a configuração de tempo desejada
    Stride é utilizado pois a quantidade de elementos a serem copiados é sempre maior que a quantidade de threads
    As bordas
    */
    for (int stride = blockThreadIndex; stride < sharedTam; stride += (blockDim.x * blockDim.y))
    {
         int sharedIdxX = stride % Dx;
         int sharedIdxY = int(stride / Dx);
         int globalIdxX =(blockIdx.x * blockDim.x) + sharedIdxX - times;
         int globalIdxY =(blockIdx.y * blockDim.y) + sharedIdxY - times;
         //int globalIdx = globalIdxX + (globalIdxX < 0) - (globalIdxX >= X)  +  (globalIdxY + (globalIdxY < 0) - (globalIdxY >= Y)) * X;
         int globalIdx = globalIdxX + (-1*globalIdxX)*(globalIdxX < 0) - (globalIdxX-X+1)*(globalIdxX >= X)  +  (globalIdxY + (-1*globalIdxY)*(globalIdxY < 0) - (globalIdxY-Y+1)*(globalIdxY >= Y)) * X;
       
        shared[stride] = d_e[globalIdx];
        sharedV[stride] = d_v[globalIdx];
    }

    __syncthreads();

    /*
    Envia pra ser calculado todos os elementos além do ultimo instante de tempo
    */
    for (int t = 1; t < times; t++)
    {
        //_2Dstencil_(shared,sharedRes,c_coeff,Dx,Dy,k,threadIdx.x+k2,threadIdx.y+k2,Dx,threadIdx.x+k2,threadIdx.y+k2);
        int tDx = blockDim.x + ((times - t) * 2);
        int tDy = blockDim.y + ((times - t) * 2);
        int tk2 = (t);
        
        // int tDx = blockDim.x+(1*k);
        // int tDy = blockDim.y+(1*k);
        // int tk2 = (1)*k/2;
        int tSharedTam = tDx * tDy;
        for (int stride = blockThreadIndex; stride < tSharedTam; stride += (blockDim.x * blockDim.y))
        {
            //int globalIdx = (stride % tDx) + tk2 + Dx*(int(stride / Dx)) + tk2;
            //destinyTest(shared, Dx, (stride % tDx) + tk2, int(stride / Dx) + tk2,t+1);
            _2Dstencil_(shared, sharedRes, sharedV, Dx, (stride % tDx) + tk2, (int(stride / tDx)) + tk2, Dx, (stride % tDx) + tk2, (int(stride / tDx)) + tk2);
        }

        // __syncthreads();
        // for (int stride = blockThreadIndex; stride < sharedTam; stride += (blockDim.x * blockDim.y))
        // {
        //     shared[stride] = sharedRes[stride];
        // }
        float * temp = shared;
        shared = sharedRes;
        sharedRes = temp;
        __syncthreads();
    }
    /*
    Envia pra ser calculado todos os elementos do ultimo instante de tempo
   */
   
    _2Dstencil_(shared, d_r, sharedV, Dx, ((x%(blockDim.x))+times), ((y%(blockDim.y))+times), X, x, y);
    __syncthreads();
    int globalIdx = x + y * X;
    int sharedIdx = ((x%(blockDim.x))+times) + ((y%(blockDim.y))+times)*Dx;
    d_v[globalIdx] = sharedV[sharedIdx];
    if(eraseMiddle && x > X/2)
    {
        d_r[globalIdx] = 0.0f;
        //d_v[globalIdx] = 0.5f;
    }
        

    //  for(int stride=blockThreadIndex;stride<sharedTam;stride+=(blockDim.x*blockDim.y))
    // {
    //      int globalIdx = (blockIdx.x*blockDim.x)-k2+stride%Dx + ((blockIdx.y*blockDim.y)-k2+stride/Dx)*X;
    //     if(globalIdx > 0 && (blockIdx.x*blockDim.x)-k2+stride%Dx < X && ((blockIdx.y*blockDim.y)-k2+stride/Dx)<Y)
    //      d_r[globalIdx] = sharedRes[stride];
    //  }
    
    //destinyTest(d_r,X, x, y,1.0f);
    // __syncthreads();
    // for (int stride = blockThreadIndex; stride < sharedTam; stride += (blockDim.x * blockDim.y))
    // {
    //      int globalIdxX = (blockIdx.x * blockDim.x) - k2 + stride % Dx;
    //      int globalIdxY = ((blockIdx.y * blockDim.y) - k2 + int(stride / Dx));
    //      int globalIdx = globalIdxX + (globalIdxX==-1) - (globalIdxX==X)      +      (globalIdxY + (globalIdxY==-1) - (globalIdxY==Y)) * X;
    //      if(blockIdx.x == 1 && blockIdx.y == 1)
    //         d_r[globalIdx] = shared[stride];
    // }
    // __syncthreads();
    
         //int sharedIdx = ((x%(blockDim.x))+times) + ((y%(blockDim.y))+times)*Dx;
        // int sharedIdxX = (blockIdx.x * blockDim.x) + times; 
        // int sharedIdxY = (blockIdx.y * blockDim.y) + times;
        // int sharedIdx = sharedIdxX + sharedIdxY*Dx;
        //int sharedIdx = ((x%(blockDim.x))+times) + ((y%(blockDim.y))+times)*Dx;
        // int globalIdx = x + y * X;
         //if(blockIdx.x == 0 && blockIdx.y ==1)
          //d_v[globalIdx] = sharedV[sharedIdx];
    
   
}

int main(int argc, char *argv[])
{
    /*
    Declarações e valores padroes
    */
    float *h_e, *h_r, *h_v;
    float *d_e, *d_r, *d_v;
    int size, sharedSize;
    int X = 32;
    int Y = 32;
    int times = 1,globalTimes = 1;
    int BX = 32;
    int BY = 32;
    int GX = 1;
    int GY = 1;

    /*
    Obtenção dos parâmetros de entrada
    */
    if (argc > 1)
    {
        X = atoi(argv[1]);
        Y = X;
    }
    if (argc > 2)
    {
        times = atoi(argv[2]);
    }

    if (argc > 3)
    {
        globalTimes = atoi(argv[3]);
    }

    if (X > 32)
    {
        GX = ceil((float)X / (float)32);
        BX = 32;
    }
    if (Y > 32)
    {
        GY = ceil((float)Y / (float)32);
        BY = 32;
    }

    /*
    Allocações de memória e configuração dos blocos e grid
    */
    dim3 block_dim(BX, BY, 1);
    dim3 grid_dim(GX, GY, 1);
    //sharedSize = ((block_dim.x+k)*(block_dim.y+k))*sizeof(int);
    sharedSize = ((block_dim.x + (2 * times)) * (block_dim.y + (2 * times))) * sizeof(float) * 3;
    //sharedTam = ((block_dim.x+(k*2))*(block_dim.y+(k*2)));
    size = X * Y * sizeof(float);
    //tam = X * Y;

    h_e = (float *)malloc(size);
    h_r = (float *)malloc(size);
    h_v = (float *)malloc(size);
    HANDLE_ERROR( cudaMalloc(&d_e, size) );
    HANDLE_ERROR( cudaMalloc(&d_r, size) );
    HANDLE_ERROR( cudaMalloc(&d_v, size) );

//Copia os dados do campo e envia para a GPU e inicializa o dominio de entrada

        


    FILE *arq;
    arq = fopen("entrada.txt", "rt");
    for (int i = 0; i < X; i++)
        for (int j = 0; j < Y; j++)
        {
            h_v[i + j * X] =0.5f;
            int temp;
            fscanf(arq," %d",&temp);
            h_e[i + j * X] = temp;
        }

    fclose(arq);
    HANDLE_ERROR( cudaMemcpy(d_v, h_v, size, cudaMemcpyHostToDevice) );
   
    /* 
    Copy vectors from host memory to device memory
    Copia os dados da entrada de volta a GPU
        */
        HANDLE_ERROR( cudaMemcpy(d_e, h_e, size, cudaMemcpyHostToDevice) );
    
    /*
    Começa o Timer
    */
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    /******************
    *** Kernel Call ***
    *******************/
    //_3Dstencil_global<<<blks,th_p_blk>>>(d_e,d_r,X,Y,Z);
    /*
    Executa o kernel
    */
    bool reseted = false;
    for(int i=0; i<globalTimes/times; i ++)
    {
        if(i*times > 8000 && !reseted)
        {
            _2Dstencil_global<<<grid_dim, block_dim, sharedSize>>>(d_e, d_r, d_v, X, Y, times,true);
            reseted = true;
        }else
        {
            _2Dstencil_global<<<grid_dim, block_dim, sharedSize>>>(d_e, d_r, d_v, X, Y, times,false);
        }

        cudaError_t err = cudaSuccess;
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            fprintf(stderr, "Failed to launch _3Dstencil_global kernel (error code %s)!\n", cudaGetErrorString(err));
        }   
            
        float * temp = d_e;
        d_e = d_r;
        d_r = temp;
    }
    

    /*
    Identifica possíveis erros
    */
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
    /*
    Para o Timer
    */
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    //printf("X %d || Y %d \nBX %d || BY %d \n",X,Y,BX,BY);
    //printf ("[%d,%.5f],\n", tam,elapsedTime);
    /*
    Copia o resultado de volta para o CPU
    */
    HANDLE_ERROR( cudaMemcpy(h_r, d_e, size, cudaMemcpyDeviceToHost) );
    /*
    Copia o resultado para a imagem de visualização
    A estrutura de 
    */
    arq = fopen("resultado.txt", "wt");
    for (int i = 0; i < X; i++)
    {
        for (int j = 0; j < Y; j++)
        {
            fprintf(arq," %6.4f",h_r[i+j*X]);
        }
        fprintf(arq,"\n");
    }
    fclose(arq);
        

    cudaFree(d_e);
    cudaFree(d_r);
    std::free(h_e);
    std::free(h_r);

    return 0;
} /* main */
