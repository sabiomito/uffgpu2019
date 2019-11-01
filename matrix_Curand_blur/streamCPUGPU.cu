
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
1- Gerar uma matriz aleatoria
2- Aplicar um blur ou filtro (gerar uma nova matriz de saida, com a media aritimetica da vizinhanca aplicada a cada elemento da matriz)
3- Testar e mandar resultados de tempo para os segintes casos:
- memoria unificada
- copia manual de memoria
- usando stream para copia CPU->GPU
- usando streams para os dois sentidos de copias (ida e volta)
4- Testar para matrizes de 100x100 , 1000x1000, 10000x10000
**/
__global__ void blur(unsigned int origData[],unsigned result[],int L,int ox,int oy) {


    int thread_idx = ox + (threadIdx.x + blockIdx.x * blockDim.x);
    int thread_idy = oy + (threadIdx.y + blockIdx.y * blockDim.y);
    
 
    
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
    unsigned int L, tam, *h_data,*d_data,*d_res;
    size_t size;
    curandGenerator_t gen;
    cudaError_t err = cudaSuccess;
    L = 40;
    if(argc > 1)
      L = atoi(argv[1]);

    tam = L*L;
    size = tam*sizeof(unsigned int);

    dim3 block_dim(L,L,1);
    dim3 grid_dim(1,1,1);
    if(L>32)
    {
        block_dim = dim3(32,32,1);
        grid_dim = dim3(ceil(L/32),ceil(L/32),1);
    }
    

    // Allocate memory for the vectors on host memory.
    h_data = (unsigned int*) malloc(size);
      
    /* Allocate vectors in device memory */
    CUDA_CALL(cudaMalloc(&d_data, size));
    CUDA_CALL(cudaMalloc(&d_res, size));

    

    cudaEvent_t start, stop;
    CUDA_CALL(cudaEventCreate (&start));
    CUDA_CALL(cudaEventCreate (&stop));
    CUDA_CALL(cudaEventRecord (start, 0)); // 0 is the stream number
    // do Work…
  
    for(int i=0; i<tam;i++)
        h_data[i]=0;

    CURAND_CALL(curandCreateGenerator(&gen,CURAND_RNG_PSEUDO_DEFAULT));
    CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen,time(NULL)));
    CURAND_CALL(curandGenerate(gen,d_data, tam));
    


    CUDA_CALL(cudaDeviceSynchronize());



    CUDA_CALL(cudaMemcpy(h_data, d_data, size, cudaMemcpyDeviceToHost));

    int rStreams = 2;
  
    /* Kernel Call */
    for(int ox=0; ox < L; ox+=tam/rStreams)
        {
            for(int oy=0; oy < L; oy+=tam/rStreams)
            {
                cudaStream_t stream0;
                cudaStreamCreate(&stream0);
                dim3 block_dim_temp = dim3(32,32,1);
                dim3 grid_dim_temp = dim3(ceil((L/rStreams)/32),ceil((L/rStreams)/32),1);
                if(ox == 0 && oy==0)
                    blur<<<grid_dim_temp,block_dim_temp>>>(d_data, d_res, L, ox, oy);
                else
                    blur<<<grid_dim_temp,block_dim_temp>>>(d_data, d_res, L+1, ox-1, oy-1);
                err = cudaGetLastError();
                if (err != cudaSuccess)
                {
                    fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
                    exit(EXIT_FAILURE);
                }
            }
        }
    
    
    

    CUDA_CALL(cudaMemcpy(h_data, d_res, size, cudaMemcpyDeviceToHost));

    CUDA_CALL(cudaDeviceSynchronize());

    for(int i=0; i<tam;i++)
        h_data[i]=0;
    
    CUDA_CALL(cudaEventRecord (stop, 0));
    
    CUDA_CALL(cudaEventSynchronize (stop));

   

    float elapsedTime;
    CUDA_CALL(cudaEventElapsedTime (&elapsedTime, start, stop));
    printf ("[%d,%.5f],\n", tam,elapsedTime);
    CUDA_CALL(cudaEventDestroy(start));
    CUDA_CALL(cudaEventDestroy(stop));
    
    /* Free device memory */
    CUDA_CALL( cudaFree(d_data));
    CUDA_CALL( cudaFree(d_res));
    /* Free host memory */
    free(h_data);

    return 0;
} /* main */

