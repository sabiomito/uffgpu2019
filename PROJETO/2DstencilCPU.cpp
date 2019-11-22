
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
int *h_e,*h_r;
int size,tam;
int X=16;
int Y=16;
int k=4;
int times = 1;
float *c_coeff;
if(argc > 1)
{
    X = atoi(argv[1]);
    Y = X;
}
if(argc > 2)
{
    k = atoi(argv[2]);
}

if(argc > 3)
{
    times = atoi(argv[3]);
}


size = X * Y * sizeof(int);
tam = X * Y ;

h_e = (int*) malloc(size);
h_r = (int*) malloc(size);
c_coeff = (float*)malloc((k/2+1)*sizeof(float));
for(int i=0;i<(k/2+1);i++)
    c_coeff[(k/2+1)-i-1]=(float)i/(float)(k/2+1);

FILE *arq;
arq = fopen("entrada.txt", "rt");
for(int i=0;i<X;i++)
    for(int j=0;j<Y;j++)
        fscanf(arq," %d",&h_e[i+j*X]);
fclose(arq);


for(int t=0;t<times;t++)
{
    
    for(int y=0;  y<Y;  y++)
    {
        for(int x=0;  x<X;  x++)
        {
            int h_r_i = x + ( y * (X) );
            int h_e_i = h_r_i;
            h_r[h_r_i] = h_e[h_e_i];
            for(int lk = 1;lk<(k/2)+1;lk++)
                {
                    if(x+lk >= X)
                        h_e_i = (x-lk) + ( (y) * (X) );
                    else
                        h_e_i = (x+lk) + ( (y) * (X) );
                    h_r[h_r_i] += h_e[h_e_i]*c_coeff[lk-1];

                    if(x-lk < 0)
                        h_e_i = (x+lk) + ( (y) * (X) );
                    else
                        h_e_i = (x-lk) + ( (y) * (X) );
                    h_r[h_r_i] += h_e[h_e_i]*c_coeff[lk-1];


                    if(y+lk >= Y)
                        h_e_i = (x) + ( (y-lk) * (X) );
                    else
                        h_e_i = (x) + ( (y+lk) * (X) );
                    h_r[h_r_i] += h_e[h_e_i]*c_coeff[lk-1];

                    if(y-lk < 0)
                        h_e_i = (x) + ( (y+lk) * (X) );
                    else
                        h_e_i = (x) + ( (y-lk) * (X) );
                    h_r[h_r_i] += h_e[h_e_i]*c_coeff[lk-1];

                }  
        }
    }

    int * temp = h_r;
    h_r = h_e;
    h_e = temp;
}



arq = fopen("resultado.txt", "wt");
for(int i=0;i<X;i++)
{
    for(int j=0;j<Y;j++)
    {
      fprintf(arq," %d",h_e[i+j*X]);
    }
    fprintf(arq,"\n");
}
fclose(arq);


    return 0;
} /* main */

