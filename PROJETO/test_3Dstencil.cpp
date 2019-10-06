
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace std;

/*
*argumentos
*1 - n_elementos
*2 - threads por bloco
*3 - n_blocos
*4 - print
*/
int main(int argc, char* argv[]) {
    int th_p_blk;
    float *h_e,*h_r_test;
    float *d_e, *d_r;
    int size,tam;

    /*FOR TESTING FIRST
    int k = 6;
    int BDi = 32;
    int GBx,GBy,Fatias;
    GBx=GBy=2;
    Fatias = 32;

    //Define size vectors
    size = BDi  * GBx * BDi  *GBy * Fatias * sizeof(float);

    tam = BDi * GBx * BDi  *GBy * Fatias;

    //dim3 dimGrid(GBx, GBy,1);
	//dim3 dimBlock(BDi, BDi, 1);

    // Allocate memory for the vectors on host memory.
    h_e = (float*) malloc(size);
    h_r_test = (float*) malloc(size);

    for (int i = 0; i < tam; i++) {
        h_e[i] = (float)(rand()%1000)/100.0;
    }

    printf("Allocou\n\n");
    */

        


   int X=100;
  int Y=100;
  int Z=10;
  int k=4;

  

  size = X * Y * Z * sizeof(float);
  tam = X * Y * Z;

  h_e = (float*) malloc(size);
    h_r_test = (float*) malloc(size);

    for (int i = 0; i < tam; i++) {
        h_e[i] = (float)(rand()%9000)/100.0;
    }



    for(int z=0;  z<Z;  z++)
    {
       
    	for(int y=0;  y<Y;  y++)
    	{
            for(int x=0;  x<X;  x++)
    	    {
                
                
                int h_r_i = x + ( y * (X) ) + ( z* (X*Y) );
                    
                int h_e_i = h_r_i;
                h_r_test[h_r_i] = h_e[h_e_i];
                //printf("x %d y %d z %d valA %f\n",x,y,z, h_r_test[h_r_i]);
                for(int lk =0;lk<(k/2);lk++)
                    {
                        

                        
                        if(x+lk >= X)
                            h_e_i = (x-lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                        else
                            h_e_i = (x+lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                        if(x-lk < 0)
                            h_e_i = (x+lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                        else
                            h_e_i = (x-lk) + ( (y) * (X) ) + ( (z) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];


                        if(y+lk >= Y)
                            h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                        else
                            h_e_i = (x) + ( (y+lk) * (X) ) + ( (z) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                        if(y-lk < 0)
                            h_e_i = (x) + ( (y+lk) * (X) ) + ( (z) * (X*Y) );
                        else
                            h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];


                         if(z+lk >= Z)
                            h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                        else
                             h_e_i = (x) + ( (y) * (X) ) + ( (z+lk) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                        if(z-lk < 0)
                             h_e_i = (x) + ( (y) * (X) ) + ( (z+lk) * (X*Y) );
                        else
                            h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                    }
                    //printf("x %d y %d z %d valD %f\n\n",x,y,z, h_r_test[h_r_i]);
                
                 
            }
    	}
       
    }
    /* code */



    free(h_e);
    free(h_r_test);

    return 0;
} /* main */

