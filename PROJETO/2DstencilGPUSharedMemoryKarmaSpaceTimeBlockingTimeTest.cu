#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <string>
/*
Instruções
COMPILAR -->  nvcc 2DstencilGPUSharedMemoryBlankBorderTimeSpaceSharingOpencvKarma.cu -o go `pkg-config --cflags --libs opencv` -w
EXECUTAR --> ./go DOMAIN_DIMS STENCIL_ORDER SPACE_TIME_BLOCK_TIMES BLOCK_DIM_X BLOCK_DIM_Y
*/



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
    h_e_i = Gx + ((Gy) * (GX));
    d_r[h_e_i] = temp;
    

}
/*
função chamada pelo host que controla as cópias e a ordem do calculo dos stencils bem como a carga para cada thread
*/
__global__ void _2Dstencil_global(float *d_e, float *d_r, float *d_v, int X, int Y, int times)
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
         int globalIdx = globalIdxX*(!(globalIdxX < 0 || globalIdxX >= X)) + (globalIdxX + (globalIdxX < 0) - (globalIdxX >= X))*((globalIdxX < 0 || globalIdxX >= X))  +   (globalIdxY*(!(globalIdxY < 0 || globalIdxY >= Y)) + (globalIdxY + (globalIdxY < 0) - (globalIdxY >= Y))*((globalIdxY < 0 || globalIdxY >= Y))) * X;
     
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
        int tSharedTam = tDx * tDy;
        for (int stride = blockThreadIndex; stride < tSharedTam; stride += (blockDim.x * blockDim.y))
        {
            _2Dstencil_(shared, sharedRes, sharedV, Dx, (stride % tDx) + tk2, (int(stride / tDx)) + tk2, Dx, (stride % tDx) + tk2, (int(stride / tDx)) + tk2);
        }

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
    
    int sharedIdx = ((x%(blockDim.x))+times) + ((y%(blockDim.y))+times)*Dx;
    int globalIdx = x + y * X;
    d_v[globalIdx] = sharedV[sharedIdx];
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
        if (argc > 4)
            BX = atoi(argv[4]);
        GX = ceil((float)X / (float)BX);
        BX = 32;
    }
    if (Y > 32)
    {
        if (argc > 5)
            BY = atoi(argv[5]);
        GY = ceil((float)Y / (float)BY);
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
    cudaMalloc(&d_e, size);
    cudaMalloc(&d_r, size);
    cudaMalloc(&d_v, size);

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
    cudaMemcpy(d_v, h_v, size, cudaMemcpyHostToDevice);
   
    /* 
    Copy vectors from host memory to device memory
    Copia os dados da entrada de volta a GPU
        */
    cudaMemcpy(d_e, h_e, size, cudaMemcpyHostToDevice);
    
    /*
    Começa o Timer
    */
    cudaDeviceSynchronize();
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
    for(int i=0; i<globalTimes/times; i ++)
    {
        _2Dstencil_global<<<grid_dim, block_dim, sharedSize>>>(d_e, d_r, d_v, X, Y, times);
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

    printf ("[%d,%.5f]",times,elapsedTime);

    // arq = fopen("TempoExecucaoBlocking12000VariandoTimes.txt", "a");
    // //printf("X %d || Y %d \nBX %d || BY %d \n",X,Y,BX,BY);
    // // float sharedTime = 0.0;
    // //     if(MODEL_WIDTH == 64)
    // //         sharedTime = 108.41396;
    // //     if(MODEL_WIDTH == 96)
    // //         sharedTime = 89.01120;
    // //     if(MODEL_WIDTH == 128)
    // //         sharedTime = 95.11117;
    // //     if(MODEL_WIDTH == 160)
    // //         sharedTime = 113.37702;
    // //     if(MODEL_WIDTH == 192)
    // //         sharedTime = 101.13689;
    // //     if(MODEL_WIDTH == 224)
    // //         sharedTime = 154.31091;
    // //     if(MODEL_WIDTH == 256)
    // //         sharedTime = 186.73097;
    // //     if(MODEL_WIDTH == 288)
    // //         sharedTime = 218.92052;
    // //     if(MODEL_WIDTH == 320)
    // //         sharedTime = 232.28406;
    // //     if(MODEL_WIDTH == 352)
    // //         sharedTime = 295.31876;
    // //     if(MODEL_WIDTH == 384)
    // //         sharedTime = 304.94522;
    // //     if(MODEL_WIDTH == 416)
    // //         sharedTime = 385.76855;
    // //     if(MODEL_WIDTH == 448)
    // //         sharedTime = 570.88287;
    // //     if(MODEL_WIDTH == 480)
    // //         sharedTime = 701.02271;
    // //     if(MODEL_WIDTH == 512)
    // //         sharedTime = 768.65991;
    // //     if(MODEL_WIDTH == 544)
    // //         sharedTime = 881.91882;
    // //     if(MODEL_WIDTH == 576)
    // //         sharedTime = 979.11212;
    // //     if(MODEL_WIDTH == 608)
    // //         sharedTime = 1082.10193;
    // //     if(MODEL_WIDTH == 640)
    // //         sharedTime = 1188.77576;
    // //     if(MODEL_WIDTH == 672)
    // //         sharedTime = 1316.50024;
    // //     if(MODEL_WIDTH == 704)
    // //         sharedTime = 1436.11035;
    // //     if(MODEL_WIDTH == 736)
    // //         sharedTime = 1532.38489;
    // //     if(MODEL_WIDTH == 768)
    // //         sharedTime = 1576.36401;

    // fprintf (arq,"(%d,%.5f),\n",times,elapsedTime);//,sharedTime);
    // fclose(arq);
    /*
    Copia o resultado para a imagem de visualização
    */
    cudaMemcpy(h_r, d_e, size, cudaMemcpyDeviceToHost);
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
