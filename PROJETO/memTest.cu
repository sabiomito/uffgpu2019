#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <fstream>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <opencv2/imgcodecs.hpp>
#include <math.h>
#include <string>

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        X = atoi(argv[1]);
        Y = X;
    }

    size = X * Y * sizeof(float);
    float * h_e = (float *)malloc(size);
    std::free(h_e);
}