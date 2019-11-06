
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
   int X=100;
  int Y=100;
  int Z=10;
  int k=4;
  int times = 10;

  

  size = X * Y * Z * sizeof(float);
  tam = X * Y * Z;

  h_e = (float*) malloc(size);
    h_r_test = (float*) malloc(size);

    for (int i = 0; i < tam; i++) {
        h_e[i] = (float)(rand()%9000)/100.0;
    }


for(int t=0;t<times;t++)
{
    for(int z=0;  z<Z;  z++)
    {
       
    	for(int y=0;  y<Y;  y++)
    	{
            for(int x=0;  x<X;  x++)
    	    {
                int h_r_i = x + ( y * (X) ) + ( z* (X*Y) );
                int h_e_i = h_r_i;
                h_r_test[h_r_i] = h_e[h_e_i];
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
            }
    	}
    }
    float * temp = h_r_test;
    h_r_test = h_e;
    h_e = temp;
}

    free(h_e);
    free(h_r_test);

    return 0;
} /* main */

