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
    int *h_data,L,tam,print;
    size_t size;
    curandGenerator_t gen;
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
    

    curandCreateGeneratorHost(&gen,CURAND_RNG_PSEUDO_DEFAULT);
    curandSetPseudoRandomGeneratorSeed(gen,time(NULL));
    curandGenerate(gen,(unsigned int *)h_data, size);
    
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

   
	curandDestroyGenerator(gen);
	out.close();

    /* Free host memory */
    free(h_data);
    return 0;
} /* main */


