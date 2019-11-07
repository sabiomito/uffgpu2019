#include <stdlib.h>
#include <stdio.h>
#include <curand.h>
#include <time.h> 
#include <iostream>
#include <string>
#include <fstream>
using namespace std;

#define CURAND_CALL(x) do { if((x)!=CURAND_STATUS_SUCCESS) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)


int main(int argc, char* argv[]) {
    int *h_data,*d_data,L,tam,print;
    size_t size;
    curandRngType_t type = CURAND_RNG_PSEUDO_DEFAULT;
    curandGenerator_t gen;
    L=10;
    if(argc > 1)
        L = atoi(argv[1]);
    if(argc > 2)
        print = atoi(argv[2]);
    if(argc > 3)
        if(strcmp(argv[3],"CURAND_RNG_PSEUDO_DEFAULT")==0)
            type = CURAND_RNG_PSEUDO_DEFAULT;
        else if(strcmp(argv[3],"CURAND_RNG_PSEUDO_MRG32K3A")==0)
            type = CURAND_RNG_PSEUDO_MRG32K3A;
        else if(strcmp(argv[3],"CURAND_RNG_PSEUDO_MT19937")==0)
            type = CURAND_RNG_PSEUDO_MT19937;
        else if(strcmp(argv[3],"CURAND_RNG_PSEUDO_XORWOW")==0)
            type = CURAND_RNG_PSEUDO_XORWOW;
        else if(strcmp(argv[3],"CURAND_RNG_PSEUDO_MTGP32")==0)
            type = CURAND_RNG_PSEUDO_MTGP32;
        else if(strcmp(argv[3],"CURAND_RNG_PSEUDO_PHILOX4_32_10")==0)
            type = CURAND_RNG_PSEUDO_PHILOX4_32_10;
        else if(strcmp(argv[3],"CURAND_RNG_QUASI_DEFAULT")==0)
            type = CURAND_RNG_QUASI_DEFAULT;
        else if(strcmp(argv[3],"CURAND_RNG_QUASI_SCRAMBLED_SOBOL32")==0)
            type = CURAND_RNG_QUASI_SCRAMBLED_SOBOL32;
        else if(strcmp(argv[3],"CURAND_RNG_QUASI_SCRAMBLED_SOBOL64")==0)
            type = CURAND_RNG_QUASI_SCRAMBLED_SOBOL64;
        else if(strcmp(argv[3],"CURAND_RNG_QUASI_SOBOL32")==0)
            type = CURAND_RNG_QUASI_SOBOL32;
        else if(strcmp(argv[3],"CURAND_RNG_QUASI_SOBOL64")==0)
            type = CURAND_RNG_QUASI_SOBOL64;
    tam = L*L;
    size = tam*sizeof(int);
    

    // Allocate memory for the vectors on host memory.
    h_data = (int*) malloc(size);
    for (int i = 0; i < tam; i++)
        h_data[i] = 0;

    cudaMalloc((void **)&d_data, size);

    if( curandCreateGenerator(&gen,type) != CURAND_STATUS_SUCCESS)
    {
        printf("Error at %s:%d\n",__FILE__,__LINE__);
        return EXIT_FAILURE;
    }
    
    curandSetPseudoRandomGeneratorSeed(gen,0);
    curandGenerate(gen,(unsigned int *)d_data, size);

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
    curandDestroyGenerator(gen);
    /* Free host memory */
    free(h_data);
    cudaFree(d_data);
    return 0;
} /* main */


