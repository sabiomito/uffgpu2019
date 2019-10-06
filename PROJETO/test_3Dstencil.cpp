
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <opencv2/imgcodecs.hpp>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
using namespace cv;
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
        char *m_name = "resultado";
		namedWindow(m_name, WINDOW_NORMAL & CV_GUI_NORMAL);
        int tam_ja=400;
		moveWindow(m_name, tam_ja , tam_ja);
		resizeWindow(m_name, tam_ja, tam_ja);

        


   int X=100;
  int Y=100;
  int Z=10;
  int k=2;

  
  vector<Mat> imgs;
  

  size = X * Y * Z * sizeof(float);
  tam = X * Y * Z;

  h_e = (float*) malloc(size);
    h_r_test = (float*) malloc(size);

    for (int i = 0; i < tam; i++) {
        h_e[i] = (float)(rand()%9000)/100.0;
    }

while (true)
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
                            h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                        else
                             h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                        if(z-lk < 0)
                             h_e_i = (x) + ( (y) * (X) ) + ( (z-lk) * (X*Y) );
                        else
                            h_e_i = (x) + ( (y-lk) * (X) ) + ( (z) * (X*Y) );
                        h_r_test[h_r_i] += h_e[h_e_i];

                    }
                    h_r_test[h_r_i]/=6;
                    //printf("x %d y %d z %d valD %f\n\n",x,y,z, h_r_test[h_r_i]);
                
                 
            }
    	}
        Mat img = Mat::zeros(X,Y,CV_8UC1);
        float maior = FLT_MIN;
        for (int i = 0; i < X*Y; i++)
            if(h_r_test[i]>maior)
                maior = h_r_test[i+ ( (z) * (X*Y) )];
        
        for (int i = 0; i < X*Y; i++)
        {  
            img.at<uchar>(i) =(int)(h_r_test[i+ ( (z) * (X*Y) )]/maior*255);
        }
        printf("imgs size %d\n",imgs.size());
        imgs.push_back(img);
    }

    for (int i = 0; i < tam; i++) 
    {
        h_e[i] = h_r_test[i];
    }
   
    int i=0;
    while (true)
	{
        if(i >= imgs.size())
            i=0;
        
        char txt[35];
        sprintf(txt,"Fatia %d",i);
        putText(imgs[i], txt, cvPoint(5,15),FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(255,255,255), 1, CV_AA);
                
        imshow(m_name, imgs[i]);
        if (waitKey(0) == 27) //ESC == 27
        {
            break;
        }
        i++;
	}


    printf("imgs size %d\n",imgs.size());
    imgs.clear();

    /* code */
}


    std::free(h_e);
    std::free(h_r_test);

    return 0;
} /* main */

