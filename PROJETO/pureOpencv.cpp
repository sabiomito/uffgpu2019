/*
COMPILE -->  g++ main.cpp -o main.exe `pkg-config --cflags --libs opencv` -w
EXECUTE --> ./main.exe
*/

#include <iostream>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <opencv2/imgcodecs.hpp>
#include <math.h>
#include <string>

#define JAN_OFFSET 0
using namespace cv;
using namespace std;

class Window
{
	char *m_name;

public:
	Window(char *name, int tam_ja, int x, int y)
	{
		m_name = name;
		namedWindow(m_name, WINDOW_NORMAL & CV_GUI_NORMAL);
		moveWindow(m_name, tam_ja * x + JAN_OFFSET, tam_ja * y + JAN_OFFSET);
		resizeWindow(m_name, tam_ja, tam_ja);
	}
	void imshow(Mat img)
	{
		cv::imshow(m_name, img);
	}
	void createTrackbar(char *trackName, int *var, int max_val)
	{
		cv::createTrackbar(trackName, m_name, var, max_val);
	}
};

// Finally our main arrives!
int main(int argc, char **argv)
{

	
	if (argc < 2)
	{
		printf("\nespecifique a imagem\n");
		return -1;
	}
	Mat orig =imread("doidera2.PNG");
	Window original("orig", 400, 0, 0);

	while (true)
	{
		original.imshow(orig);
		
		// Wait for key is pressed then break loop
		if (waitKey(5) == 27) //ESC == 27
		{
			break;
		}
	}

	return 0;
}
