
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <curand.h>
#include <time.h> 
#define CUDA_CALL(x) do { if((x)!=cudaSuccess) { \
    printf("Error at %s:%d : err => %s\n",__FILE__,__LINE__,cudaGetErrorString(x));\
    return EXIT_FAILURE;}} while(0)
#define CURAND_CALL(x) do { if((x)!=CURAND_STATUS_SUCCESS) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)
/**
- memoria unificada
[10000,0.02410],
[1000000,0.12742],
[100000000,10.52038],
1- Gerar uma matriz aleatoria
2- Aplicar um blur ou filtro (gerar uma nova matriz de saida, com a media aritimetica da vizinhanca aplicada a cada elemento da matriz)
3- Testar e mandar resultados de tempo para os segintes casos:
- memoria unificada
- copia manual de memoria
- usando stream para copia CPU->GPU
- usando streams para os dois sentidos de copias (ida e volta)
4- Testar para matrizes de 100x100 , 1000x1000, 10000x10000
**/
__global__ void blur(unsigned int origData[],unsigned result[],int L) {


    int thread_idx = threadIdx.x + blockIdx.x * blockDim.x;
    int thread_idy = threadIdx.y + blockIdx.y * blockDim.y;
    

    if(thread_idx-1 >= 0 && thread_idx+1 < L && thread_idy-1 >= 0 && thread_idy+1 < L)
    {
        int temp = origData[(thread_idx) + (thread_idy)*L];
        temp += origData[(thread_idx-1) + (thread_idy-1)*L];
        temp += origData[(thread_idx) + (thread_idy-1)*L];
        temp += origData[(thread_idx+1) + (thread_idy-1)*L];

        temp += origData[(thread_idx-1) + (thread_idy)*L];
        //temp += origData[(thread_idx) + (thread_idy)*L];
        temp += origData[(thread_idx+1) + (thread_idy)*L];

        temp += origData[(thread_idx-1) + (thread_idy+1)*L];
        temp += origData[(thread_idx) + (thread_idy+1)*L];
        temp += origData[(thread_idx+1) + (thread_idy+1)*L];
        result[(thread_idx) + (thread_idy)*L] = temp/9;
    }else
    {
        result[(thread_idx) + (thread_idy)*L] = origData[(thread_idx) + (thread_idy)*L];
    }
        
}
/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*/
int main(int argc, char* argv[]) {
    unsigned int L, tam, *data,*res;
    size_t size;
    cudaError_t err = cudaSuccess;
    L = 40;
    if(argc > 1)
      L = atoi(argv[1]);

    tam = L*L;
    size = tam*sizeof(unsigned int);
    cudaMallocManaged(&data,size);
    cudaMallocManaged(&res,size);

    
    cudaEvent_t start, stop;
    CUDA_CALL(cudaEventCreate (&start));
    CUDA_CALL(cudaEventCreate (&stop));
    CUDA_CALL(cudaEventRecord (start, 0)); // 0 is the stream number

    

    dim3 block_dim(L,L,1);
    dim3 grid_dim(1,1,1);
    if(L>32)
    {
        block_dim = dim3(32,32,1);
        grid_dim = dim3(ceil(L/32),ceil(L/32),1);
    }
    

    srand(time(NULL));
    for(int i=0; i<tam;i++)
        data[i]=rand();


    // do Work…
    
    /* Kernel Call */
    blur<<<grid_dim,block_dim>>>(data,res, L);
    err = cudaGetLastError();

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
    
    CUDA_CALL(cudaDeviceSynchronize());
    
   
    for(int i=0; i<tam;i++)
        data[i]=0;
    
    CUDA_CALL(cudaEventRecord (stop, 0));
    CUDA_CALL(cudaEventSynchronize (stop));
    
    float elapsedTime;
    CUDA_CALL(cudaEventElapsedTime (&elapsedTime, start, stop));
    printf ("[%d,%.5f],\n", tam,elapsedTime);
    CUDA_CALL(cudaEventDestroy(start));
    CUDA_CALL(cudaEventDestroy(stop));
    
 
    
    /* Free device memory */
    CUDA_CALL( cudaFree(data));
    CUDA_CALL( cudaFree(res));


    return 0;
} /* main */

