
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <curand.h>
#include <time.h> 
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
__global__ void blur(unsigned int origData[],unsigned result[],int L) {


    int thread_idx = threadIdx.x + blockIdx.x * blockDim.x;
    int thread_idy = threadIdx.y + blockIdx.y * blockDim.y;
    
    
    if(thread_idx-1 >= 0 && thread_idx+1 <= L && thread_idy-1 >= 0 && thread_idy+1 <= L)
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
    unsigned int L,G, tam, *h_data,*d_data,*d_res;
    size_t size;
    curandGenerator_t gen;

    unsigned int th_p_blk = 1024;
    L = 40;
    G = 1;
    if(argc > 1)
      L = atoi(argv[1]);
    if(argc > 2)
      G = atoi(argv[2]);

    tam = L*L;
    size = tam*sizeof(unsigned int);

    dim3 block_dim(ceil(L/G),ceil(L/G),1);
    dim3 grid_dim(G,G,1);

    bool print = false;
    if(L<33)
        print = true;
    // Allocate memory for the vectors on host memory.
    h_data = (unsigned int*) malloc(size);

    for (int i = 0; i < tam; i++)
        h_data[i] = 0;
    
    

    /* Allocate vectors in device memory */
    cudaMalloc(&d_data, size);
    cudaMalloc(&d_res, size);
    curandCreateGenerator(&gen,CURAND_RNG_PSEUDO_DEFAULT);
    curandSetPseudoRandomGeneratorSeed(gen,time(NULL));
    curandGenerate(gen,d_data, size);
    

    cudaMemcpy(h_data, d_data, size, cudaMemcpyDeviceToHost);
    if(print)
    {
        printf("\n\n");
        for (int i = 0; i < tam; i++)
        {
            if(i%L==0)
                printf("\n");
            printf(" %u",h_data[i]);
        }
        printf("\n\n");
    }

    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…
    
    /* Kernel Call */
    blur<<<grid_dim,block_dim>>>(d_data, d_res, L);
    
    cudaDeviceSynchronize();
    
    cudaEventRecord (stop, 0);
    
    cudaEventSynchronize (stop);
    
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    printf ("[%d,%.5f],\n", tam,elapsedTime);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
 
    cudaMemcpy(h_data, d_res, size, cudaMemcpyDeviceToHost);
    if(print)
    {
        printf("\n\n");
        for (int i = 0; i < tam; i++)
        {
            if(i%L==0)
                printf("\n");
            printf(" %u",h_data[i]);
        }
        printf("\n\n");
    }


    /* Free device memory */
    cudaFree(d_data);
    cudaFree(d_res);
    /* Free host memory */
    free(h_data);

    return 0;
} /* main */

