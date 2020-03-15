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

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <math.h>
#include <string>

using namespace std;

//===> CONSTANTES karma model <===//
#ifndef MODEL_WIDTH
#define MODEL_WIDTH 96
#endif

#ifndef BLOCK_TIMES
#define BLOCK_TIMES 1
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

#define MODELSIZE_X (MODEL_WIDTH)
#define MODELSIZE_Y (MODEL_WIDTH)
#define MODELSIZE_Z 1
#define MODELSIZE2D ( MODELSIZE_X*MODELSIZE_Y )

#ifndef BLOCKDIM_X
#define BLOCKDIM_X 32
#endif

#ifndef BLOCKDIM_Y
#define BLOCKDIM_Y 32
#endif

#define BLOCKDIM_Z 1
#define BLOCKDIM2D ( BLOCKDIM_X*BLOCKDIM_Y )

//==> CUDA GRID <==//
#define GRIDDIM_X ( ( MODELSIZE_X / BLOCKDIM_X ) + ( ( MODELSIZE_X % BLOCKDIM_X ) > 0 ) )
#define GRIDDIM_Y ( ( MODELSIZE_Y / BLOCKDIM_Y ) + ( ( MODELSIZE_Y % BLOCKDIM_Y ) > 0 ) )
#define GRIDDIM_Z 1

#define SHARED_TAM ((BLOCKDIM_X + (2 * BLOCK_TIMES)) * (BLOCKDIM_Y + (2 * BLOCK_TIMES)))
#define SHARED_DX (BLOCKDIM_X + (2 * BLOCK_TIMES))
#define SHARED_DY (BLOCKDIM_Y + (2 * BLOCK_TIMES))
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
__forceinline__ __device__ void _2Dstencil_(float *d_e, float *d_r, float *d_v, int X, int x, int y, int GX, int Gx, int Gy)
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
    h_e_i = Gx + ((Gy) * (GX));
    d_r[h_e_i] = temp;
}
/*
função chamada pelo host que controla as cópias e a ordem do calculo dos stencils bem como a carga para cada thread
, MODELSIZE_X, MODELSIZE_Y, BLOCK_TIMES
 int X, int Y, int times
*/
__global__ void _2Dstencil_global(float *d_e, float *d_r, float *d_v)
{

    int x, y; //,h_e_i,h_r_i,Xs,Ys,Dx,Dy;
    x = threadIdx.x + (blockIdx.x * BLOCKDIM_X);
    y = threadIdx.y + (blockIdx.y * BLOCKDIM_Y);
    extern __shared__ float sharedOrig[];

    int blockThreadIndex = threadIdx.x + threadIdx.y * BLOCKDIM_X;

    float * shared = sharedOrig;
    float * sharedRes = shared + SHARED_TAM;
    float * sharedV = sharedRes + SHARED_TAM; 
    /*
    Copia o Tile de memória compartilhada necessária para a configuração de tempo desejada
    Stride é utilizado pois a quantidade de elementos a serem copiados é sempre maior que a quantidade de threads
    As bordas
    */
    for (int stride = blockThreadIndex; stride < SHARED_TAM; stride += (BLOCKDIM_X * BLOCKDIM_Y))
    {
        int sharedIdxX = stride % SHARED_DX;
        int sharedIdxY = int(stride / SHARED_DX);
        int globalIdxX = (blockIdx.x * BLOCKDIM_X) + sharedIdxX - BLOCK_TIMES;
        int globalIdxY = (blockIdx.y * BLOCKDIM_Y) + sharedIdxY - BLOCK_TIMES;
        int globalIdx = globalIdxX + (-1*globalIdxX)*(globalIdxX < 0) - (globalIdxX-MODELSIZE_X+1)*(globalIdxX >= MODELSIZE_X)  +  (globalIdxY + (-1*globalIdxY)*(globalIdxY < 0) - (globalIdxY-MODELSIZE_Y+1)*(globalIdxY >= MODELSIZE_Y)) * MODELSIZE_X;
       
        shared[stride] = d_e[globalIdx];
        sharedV[stride] = d_v[globalIdx];
    }

    __syncthreads();

    /*
    Envia pra ser calculado todos os elementos além do ultimo instante de tempo
    */
    for (int t = 1; t < BLOCK_TIMES; t++)
    {
        int tDx = BLOCKDIM_X + ((BLOCK_TIMES - t) * 2);
        int tDy = BLOCKDIM_Y + ((BLOCK_TIMES - t) * 2);
        int tk2 = (t);
        int tSharedTam = tDx * tDy;
        for (int stride = blockThreadIndex; stride < tSharedTam; stride += (BLOCKDIM_X * BLOCKDIM_Y))
        {
            int tempX = (stride % tDx) + tk2;
            int tempY = (int(stride / tDx)) + tk2;
            _2Dstencil_(shared, sharedRes, sharedV, SHARED_DX, tempX, tempY, SHARED_DX, tempX, tempY);
        }

        float * temp = shared;
        shared = sharedRes;
        sharedRes = temp;
        __syncthreads();
    }
    /*
    Envia pra ser calculado todos os elementos do ultimo instante de tempo
   */
    _2Dstencil_(shared, d_r, sharedV, SHARED_DX, ((x%(BLOCKDIM_X))+BLOCK_TIMES), ((y%(BLOCKDIM_Y))+BLOCK_TIMES), MODELSIZE_X, x, y);
    
     int globalIdx = x + y * MODELSIZE_X;
     int sharedIdx = ((x%(BLOCKDIM_X))+BLOCK_TIMES) + ((y%(BLOCKDIM_Y))+BLOCK_TIMES)*SHARED_DX;
     d_v[globalIdx] = sharedV[sharedIdx];
}

int main(int argc, char *argv[])
{
    /*
    Declarações e valores padroes
    */
    //float *h_e, *h_r, *h_v;
    bool resultado = false;
    float *h_e, *h_v;
    float *d_e, *d_r, *d_v;
    int sharedSize;
    int globalTimes = 1;

    /*
    Obtenção dos parâmetros de entrada
    */
    if (argc > 1)
    {
        globalTimes = atoi(argv[1]);
    }

    if(argc > 2)
    {
        resultado = atoi(argv[2])==1;
    }


    /*
    Allocações de memória e configuração dos blocos e grid
    */
    dim3 grid_dim(GRIDDIM_X,GRIDDIM_Y,GRIDDIM_Z);
    dim3 block_dim(BLOCKDIM_X,BLOCKDIM_Y,BLOCKDIM_Z);
    sharedSize = SHARED_TAM * sizeof(float) * 3;
    h_e = (float *)malloc(MODELSIZE2D*sizeof(float));
    h_v = (float *)malloc(MODELSIZE2D*sizeof(float));
    cudaMalloc(&d_e, MODELSIZE2D*sizeof(float));
    cudaMalloc(&d_r, MODELSIZE2D*sizeof(float));
    cudaMalloc(&d_v, MODELSIZE2D*sizeof(float));

//Copia os dados do campo e envia para a GPU e inicializa o dominio de entrada

        


    FILE *arq;
    arq = fopen("entrada.txt", "rt");
    for (int i = 0; i < MODELSIZE_X; i++)
        for (int j = 0; j < MODELSIZE_Y; j++)
        {
            h_v[i + j * MODELSIZE_X] =0.5f;
            int temp;
            fscanf(arq," %d",&temp);
            h_e[i + j * MODELSIZE_X] = temp;
        }

    fclose(arq);
    cudaMemcpy(d_v, h_v, MODELSIZE2D*sizeof(float), cudaMemcpyHostToDevice);
   
    /* 
    Copy vectors from host memory to device memory
    Copia os dados da entrada de volta a GPU
        */
    cudaMemcpy(d_e, h_e, MODELSIZE2D*sizeof(float), cudaMemcpyHostToDevice);
    
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
    for(int i=0; i<globalTimes/BLOCK_TIMES; i ++)
    {
        _2Dstencil_global<<<grid_dim, block_dim, sharedSize>>>(d_e, d_r, d_v);
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
        printf ("-1");
        cudaFree(d_e);
        cudaFree(d_r);
        cudaFree(d_v);
        std::free(h_e);
        std::free(h_v);
        fprintf(stderr, "Failed to launch _2Dstencil_global kernel (error code %s)!\n", cudaGetErrorString(err));
        return 0;
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
    //printf ("[%d,%.5f], sharedSize %d  CPUMem = %d bytes  GPUMen = %d bytes\n", times,elapsedTime,sharedSize,size*2,size*3);
    //printf("GPU elapsed time: %f s (%f milliseconds)\n", (elapsedTime/1000.0), elapsedTime);
    printf ("%.5f",elapsedTime);
    /*
    Copia o resultado de volta para o CPU
    */
    cudaMemcpy(h_e, d_e, MODELSIZE2D*sizeof(float), cudaMemcpyDeviceToHost);
    /*
    Copia o resultado para a imagem de visualização
    A estrutura de 
    */
    if(resultado)
    {
        arq = fopen("resultado.txt", "wt");
        for (int i = 0; i < MODELSIZE_X; i++)
        {
            for (int j = 0; j < MODELSIZE_Y; j++)
            {
                fprintf(arq," %6.4f",h_e[i+j*MODELSIZE_X]);
            }
            fprintf(arq,"\n");
        }
        fclose(arq);
    }
    
        

    cudaFree(d_e);
    cudaFree(d_r);
    cudaFree(d_v);
    std::free(h_e);
    std::free(h_v);

    return 0;
} /* main */
