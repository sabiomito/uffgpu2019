#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <iostream>
#include <string>



//===> FINITE DIFFERENCES PARAMETERS <===//
#define DT 0.05f                   //->Time in milliseconds
#define DX ( 12.0f / MODELSIZE_X ) //->Displacement in x
#define DY ( 12.0f / MODELSIZE_Y ) //->Displacement in y

//===> CONSTANTES <===//
#define Eh 3.0f
#define En 1.0f
#define Re 0.6f
#define tauE 5.0f
#define tauN 250.0f
#define gam 0.001f
#define East 1.5415f

//===> INITIAL CONDITIONS <===//
#define v0 0.5f
#define VOLT0 3.0f

//==> DISCRETE DOMAIN <==//
#ifndef MODEL_WIDTH
#define MODEL_WIDTH 0
#endif

#define MODELSIZE_X (MODEL_WIDTH)
#define MODELSIZE_Y (MODEL_WIDTH)
#define MODELSIZE_Z 1
#define MODELSIZE2D ( MODELSIZE_X*MODELSIZE_Y )

//==> CUDA THREAD BLOCK <==//
//#define TILESIZE   32
//#define BLOCKDIM_X ( TILESIZE )
//#define BLOCKDIM_Y ( TILESIZE )

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


__global__ void timeStep( const float *voltIN, float *v, float *voltOUT )
{
    int x = blockIdx.x*BLOCKDIM_X + threadIdx.x;
    int y = blockIdx.y*BLOCKDIM_Y + threadIdx.y;

    __shared__ float U[BLOCKDIM_X+2][BLOCKDIM_Y+2];

    if ( x < MODELSIZE_X && y < MODELSIZE_Y ) 
    {
        //
        int idx = y*MODELSIZE_X + x;

        int i = threadIdx.x+1;
        int j = threadIdx.y+1;

        U[i][j] = voltIN[idx];

        __syncthreads();

        float rv = v[idx];

        if ( threadIdx.y == 0 )
        U[i][0] = voltIN[(idx - ((y>0)-(y==0))*MODELSIZE_X)];
        else if ( threadIdx.y == (BLOCKDIM_Y-1) )
        U[i][(BLOCKDIM_Y+1)] = voltIN[(idx + ((y<MODELSIZE_Y-1)-(y==MODELSIZE_Y-1))*MODELSIZE_X)];

        if ( threadIdx.x == 0 )
        U[0][j] = voltIN[(idx - (x>0) + (x==0))];
        else if ( threadIdx.x == (BLOCKDIM_X-1) )
        U[(BLOCKDIM_X+1)][j] = voltIN[(idx + (x<MODELSIZE_X-1)-(x==MODELSIZE_X-1))];
        

        float Rn = ( 1.0f / ( 1.0f - expf(-Re) ) ) - rv;
        float p = ( U[i][j] > En ) * 1.0f;
        float dv = ( Rn * p - ( 1.0f - p ) * rv ) / tauN;
        float Dn = rv * rv;
        float hE = ( 1.0f - tanh(U[i][j] - Eh) ) * U[i][j] * U[i][j] / 2.0f;
        float du = ( ( ( East - Dn ) * hE ) - U[i][j] ) / tauE;

        float xlapr = U[i+1][j] - U[i][j];
        float xlapl = U[i][j]   - U[i-1][j];
        float xlapf = U[i][j+1] - U[i][j];
        float xlapb = U[i][j]   - U[i][j-1];

        float lap = xlapr - xlapl + xlapf - xlapb;

        voltOUT[idx] = ( U[i][j] + ( du * DT ) + ( lap * DT * gam / ( DX * DX ) ) );
        v[idx]       = rv + dv*DT;
    }
}

int main( int argc, char *argv[] )
{
    int nsteps = 3; //8000;
    // if ( argc > 1 ) 
    // {
    //     char *p;
    //     long conv = strtol(argv[1], &p, 10);
    //     //
    //     // Check for errors: e.g., the string does not represent an integer
    //     // or the integer is larger than int
    //     if (*p != '\0' || conv > INT_MAX) 
    //     {
    //         printf("Error with argument 1!");
    //         return 3;
    //     }
    //     else
    //     nsteps = int(conv/DT);
    // }
    if (argc > 1)
    {
        nsteps = atoi(argv[1]);
    }
    //
    cudaEvent_t dstart,dstop;
    cudaEventCreate( &dstart );
    cudaEventCreate( &dstop );
    //
    long start, end;
    struct timeval timecheck;
    gettimeofday(&timecheck, NULL);
    start = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;
    //
    float *hvolt, *hv;
    hvolt = (float*) malloc( MODELSIZE2D*sizeof(float) );
    hv    = (float*) malloc( MODELSIZE2D*sizeof(float) );

    // int x, y, idx;
    // for( y = 0; y < MODELSIZE_Y; y++ )
    // {
    //     for( x = 0; x < MODELSIZE_X; x++ )
    //     {
    //         idx = y*MODELSIZE_X + x;
    //         //
    //         hv[idx] = 0.5f;
    //         //
    //         if ( y < 10*(MODELSIZE_Y/20) && y > 8*(MODELSIZE_Y/20) && x < 10*(MODELSIZE_Y/20) &&  x > 8*(MODELSIZE_Y/20))
    //         hvolt[idx] = VOLT0;
    //         else
    //         hvolt[idx] = 0.0f;
    //         //
    //     }
    // }

     FILE *arq;
    arq = fopen("entrada.txt", "rt");
    for(int i=0;i<MODELSIZE_X;i++)
        for(int j=0;j<MODELSIZE_Y;j++)
        {
            hv[i+j*MODELSIZE_X] = 0.5f;
            int temp;
            fscanf(arq," %d",&temp);
            hvolt[i+j*MODELSIZE_X] = temp;
        }
            
    fclose(arq);

    // FILE *prof;
    // char fpname[100];
    // sprintf(fpname, "./profiles_%d_k2D_shared.csv",MODELSIZE_X);
    // prof = fopen(fpname,"w");
    // fprintf(prof,"index,timestep,P\n");
    // fprintf(prof,"0,%6.4f",0.0);
    // fclose(prof);


    dim3 point;
    //int pointIdx;
    point.x = MODELSIZE_X/2;
    point.y = MODELSIZE_Y/2;
    point.z = 0;
   // pointIdx = point.y*MODELSIZE_X + point.x;


    //fprintf(prof,",%6.4f\n",hvolt[pointIdx]);


    float *dvoltA, *dvoltB, *dv;
    HANDLE_ERROR( cudaMalloc( (void**)&dvoltA, MODELSIZE2D*sizeof(float) ) );
    HANDLE_ERROR( cudaMalloc( (void**)&dvoltB, MODELSIZE2D*sizeof(float) ) );
    HANDLE_ERROR( cudaMalloc( (void**)&dv    , MODELSIZE2D*sizeof(float) ) );

    HANDLE_ERROR( cudaMemcpy( dvoltA, hvolt, MODELSIZE2D*sizeof(float), cudaMemcpyHostToDevice ) );
    HANDLE_ERROR( cudaMemcpy( dvoltB, hvolt, MODELSIZE2D*sizeof(float), cudaMemcpyHostToDevice ) );
    HANDLE_ERROR( cudaMemcpy( dv    , hv   , MODELSIZE2D*sizeof(float), cudaMemcpyHostToDevice ) );

    free( hv );

    dim3 blocks(GRIDDIM_X,GRIDDIM_Y,GRIDDIM_Z);
    dim3 threads(BLOCKDIM_X,BLOCKDIM_Y,BLOCKDIM_Z);

    //int nsamples = (nsteps >= 2000)*2000 + (nsteps < 2000)*nsteps;
    //int j = nsteps/nsamples;
    cudaDeviceSynchronize();
    cudaEventRecord( dstart, 0 );
    int i=0;
    for (i = 0; i < nsteps; i++ ) 
    {
        if ( (i%2) == 0 ) //==> EVEN
        timeStep<<<blocks, threads>>>( dvoltA, dv, dvoltB );
        else              //==> ODD
        timeStep<<<blocks, threads>>>( dvoltB, dv, dvoltA );
        //
        /*if ( (i%j) == 0 ) {
        if ( (i%2) == 0 ) //==> EVEN
        HANDLE_ERROR( cudaMemcpy( hvolt, dvoltB, MODELSIZE3D*sizeof(float), cudaMemcpyDeviceToHost ) );
        else              //==> ODD
        HANDLE_ERROR( cudaMemcpy( hvolt, dvoltA, MODELSIZE3D*sizeof(float), cudaMemcpyDeviceToHost ) );
        //
        fprintf(prof,"%d,%6.4f,%6.4f\n", (i+1), ((i+1)*DT), hvolt[pointIdx]);
        }*/
        cudaError_t err = cudaSuccess;
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            fprintf(stderr, "Failed to launch _3Dstencil_global kernel (error code %s)!\n", cudaGetErrorString(err));
        }
    }
    cudaDeviceSynchronize();
    cudaEventRecord( dstop, 0 );
    cudaEventSynchronize ( dstop );
    float elapsed;
    cudaEventElapsedTime( &elapsed, dstart, dstop );
    //printf("GPU elapsed time: %f s (%f milliseconds)\n", (elapsed/1000.0), elapsed);

    //arq = fopen("TempoExecucaoOrig12000.txt", "a");
    //printf("X %d || Y %d \nBX %d || BY %d \n",X,Y,BX,BY);
        //fprintf (arq,"[%d,%.5f],\n",MODEL_WIDTH,elapsed);
        printf ("[%d,%.5f]",0,elapsed);
    //fclose(arq);



    // if ( (i%2) == 0 )
    // HANDLE_ERROR( cudaMemcpy( hvolt, dvoltA, MODELSIZE2D*sizeof(float), cudaMemcpyDeviceToHost ) );
    // else
    // HANDLE_ERROR( cudaMemcpy( hvolt, dvoltB, MODELSIZE2D*sizeof(float), cudaMemcpyDeviceToHost ) );


    // arq = fopen("resultado.txt", "wt");
    // for(int i=0;i<MODELSIZE_X;i++)
    // {
    //     for(int j=0;j<MODELSIZE_Y;j++)
    //     {
    //         fprintf(arq," %6.4f",hvolt[i+j*MODELSIZE_X]);
    //     }
    //     fprintf(arq,"\n");
    // }
    // fclose(arq);


    //fclose( prof );
    free( hvolt );
    cudaFree( dvoltA );
    cudaFree( dvoltB );
    cudaFree( dv );
    //
    // cudaDeviceSynchronize();
    // gettimeofday(&timecheck, NULL);
    // end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;
    //printf("CPU elapsed time: %f s (%ld milliseconds)\n", ((end - start)/1000.0), (end - start));
    //
    cudaEventDestroy( dstart );
    cudaEventDestroy( dstop );
    cudaDeviceReset();
    //
    return 0;
}
