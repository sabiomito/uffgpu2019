
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

__global__ void Mat_mul(float x[], float y[], float z[], int n, int blks) {


    int thread_id = threadIdx.x + blockIdx.x * blockDim.x;

    while(thread_id < n*n){

    	z[thread_id] = 0;
    	int linha=thread_id/n;
    	int coluna = thread_id - (linha*n);

        for(int i=0;i<n;i++)
        	z[thread_id] += (x[(i)*n+coluna] * y[linha*n+(i)]);


        thread_id+=blks*blockDim.x;
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
    int n, th_p_blk;
    float *h_x, *h_y, *h_z, *h_z_res;
    float *d_x, *d_y, *d_z;
    size_t size;

    int print = 0;
    th_p_blk = 1024;
    n = 1024;
    
    if(argc > 1)
      n = atoi(argv[1]);
    if(argc > 2)
      th_p_blk = atoi(argv[2]);


    int blks = ceil((float)n/(float)th_p_blk);

    if(argc > 3)
      blks = atoi(argv[3]);

    if(argc > 4)
    print=atoi(argv[4]);

    if(argc<1){
        printf("/*\n*argumentos\n*1 - n_elementos\n*2 - threads por bloco\n*3 - n_blocos\n*4 - print\n*/\npadrao \nn = %d\nthreads por bloco = %d\nblocos = %d\n\n",n,th_p_blk,blks);
    }
    /* Define vector length */

    size = n*n*sizeof(float);

    // Allocate memory for the vectors on host memory.
    h_x = (float*) malloc(size);
    h_y = (float*) malloc(size);
    h_z = (float*) malloc(size);
    h_z_res = (float*) malloc(size);

    for (int i = 0; i < n*n; i++) {
        h_x[i] = (int)rand()%10;
        h_y[i] = (int)rand()%10;
        h_z_res[i] = h_x[i]+h_y[i];
    }

    for(int i=0;i<n;i++)
    {
    	for(int j=0;j<n;j++)
    	{
    		h_z_res[i*n+j]=0;
            for(int k=0;k<n;k++)
            {
                h_z_res[i*n+j] += (h_x[k*n+j]*h_y[i*n+k]);
            }
            
    	}
    }
    if(print)
    {
        for(int i=0;i<n;i++)
        {
            for(int j=0;j<n;j++)
            {
                printf("%f ",h_x[i*n+j]);
            }
            printf("\n");
        }
        printf("----\n");
        for(int i=0;i<n;i++)
        {
            for(int j=0;j<n;j++)
            {
                printf("%f ",h_y[i*n+j]);
            }
            printf("\n");
        }
        printf("----\n");
        for(int i=0;i<n;i++)
        {
            for(int j=0;j<n;j++)
            {
                printf("%f ",h_z_res[i*n+j]);
            }
            printf("\n");
        }
    }
   

    /* Allocate vectors in device memory */
    cudaMalloc(&d_x, size);
    cudaMalloc(&d_y, size);
    cudaMalloc(&d_z, size);

    /* Copy vectors from host memory to device memory */
    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, size, cudaMemcpyHostToDevice);
    

    clock_t Ticks[2];
    Ticks[0] = clock();

    cudaEvent_t start, stop;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);
    cudaEventRecord (start, 0); // 0 is the stream number
    // do Work…

    /* Kernel Call */
    Mat_mul<<<blks,th_p_blk>>>(d_x, d_y, d_z, n,blks);

    cudaThreadSynchronize();
    cudaEventRecord (stop, 0);
    cudaEventSynchronize (stop);
    float elapsedTime;
    cudaEventElapsedTime (&elapsedTime, start, stop);
    printf ("[%d,%.5f],\n", n,elapsedTime);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    Ticks[1] = clock();
    double Tempo = (Ticks[1] - Ticks[0]) * 1000.0 / CLOCKS_PER_SEC;
    if(print)
    {
        printf("\n\n Tempo gasto: %g ms para:\n %d elementos \n %d blocks \n %d th_p_blk \n\n", Tempo,n,blks,th_p_blk);
    }
    //printf("%g",Tempo);
 
    cudaMemcpy(h_z, d_z, size, cudaMemcpyDeviceToHost);

    if(print)
    {
        printf("RESULTADO----\n");
        for(int i=0;i<n;i++)
        {
            for(int j=0;j<n;j++)
            {
                printf("%f ",h_z[i*n+j]);
            }
            printf("\n");
        }
    }

    bool certo=true;
    for (int i = 0; i < n*n; i++){
        if(h_z_res[i] != h_z[i])
          certo=false;
    }
    if(print)
    {
        printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");
    }
    if(!certo)
    printf("\n*****\n certo = %s\n*****\n", certo ? "true" : "false");


    /* Free device memory */
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
    /* Free host memory */
    free(h_x);
    free(h_y);
    free(h_z);
    free(h_z_res);

    return 0;
} /* main */

