#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <time.h> 
#include <curand_kernel.h>
#include <iostream>
#include <string>
#include <fstream>
using namespace std;


 __global__ void setup_kernel(curandState *state,unsigned long long seed)
 {
     int id = threadIdx.x + blockIdx.x * blockDim.x;
     curand_init(/*seed*/seed,/*sequence*/id, /*offset*/0, &state[id]);
 }
 
 __global__ void generate_kernel(curandState *state, unsigned int *result)
 {
     int id = threadIdx.x + blockIdx.x * blockDim.x;
     /* Copy state to local memory for efficiency */
     curandState localState = state[id];
     /* Generate pseudo-random unsigned ints */
     result[id] = curand(&localState);
     /* Copy state back to global memory */
     state[id] = localState;
 }

 __global__ void generate_kernel2(unsigned int *result,unsigned long long seed)
 {
     int id = threadIdx.x + blockIdx.x * blockDim.x;
     curandState state;
     curand_init(/*seed*/seed,/*sequence*/id, /*offset*/0, &state);
     result[id] = curand(&state);
 }

 
 int main(int argc, char *argv[])
 {
    int *h_data,*d_data,L,tam,print;
    size_t size;
    curandState *devStates;

    L=10;
    if(argc > 1)
        L = atoi(argv[1]);
    if(argc > 2)
        print = atoi(argv[2]);

    tam = L*L;
    size = tam*sizeof(int);
    

    // Allocate memory for the vectors on host memory.
    h_data = (int*) malloc(size);
    for (int i = 0; i < tam; i++)
        h_data[i] = 0;

    cudaMalloc((void **)&d_data, size);
    cudaMalloc((void **)&devStates, tam * sizeof(curandState));


    //setup_kernel<<<L,L>>>(devStates,time(NULL));
    //generate_kernel<<<L,L>>>(devStates, (unsigned int *) d_data);
    generate_kernel2<<<L,L>>>((unsigned int *) d_data,time(NULL));

    cudaMemcpy(h_data, d_data, size, cudaMemcpyDeviceToHost);
    
    ofstream out("data.txt");
    if(print)
    printf("\n\n");
    for (int i = 0; i < tam; i++)
    {
        if(print)
        if(i%L==0)
            printf("\n");
        out << h_data[i] << " ";
        if(print)
        printf(" %u",h_data[i]);
    }
    if(print)
    printf("\n\n");  
	
	out.close();

    /* Free host memory */
    cudaFree(devStates);
    cudaFree(d_data);
    free(h_data);
    return 0;
 
 }