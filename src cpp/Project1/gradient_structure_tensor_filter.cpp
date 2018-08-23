/**
* @brief You will learn how to segment an image by Gradient structure tensor (GST)
* @author Karpushin Vladislav, karpushin@ngs.ru, https://github.com/VladKarpushin
*/

#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"

using namespace cv;
using namespace std;

void calcGST(const Mat& inputImg, Mat& imgCoherencyOut, Mat& imgOrientationOut, int W)
{
    Mat img;
    inputImg.convertTo(img, CV_64F);

	// eigenvalue calculation (start)
	Mat imgDiffX, imgDiffY, imgDiffXY;
    Sobel(img, imgDiffX, CV_64F, 1, 0, 3);
    Sobel(img, imgDiffY, CV_64F, 0, 1, 3);
    multiply(imgDiffX, imgDiffY, imgDiffXY);

    Mat imgDiffXX, imgDiffYY;
    multiply(imgDiffX, imgDiffX, imgDiffXX);	
    multiply(imgDiffY, imgDiffY, imgDiffYY);	

    Mat imgDiffXXsmooth, imgDiffYYsmooth, imgDiffXYsmooth;
    boxFilter(imgDiffXX, imgDiffXXsmooth, CV_64F, Size(W, W));	// Jxx = imgDiffXXsmooth
    boxFilter(imgDiffYY, imgDiffYYsmooth, CV_64F, Size(W, W));	// Jyy = imgDiffYYsmooth
    boxFilter(imgDiffXY, imgDiffXYsmooth, CV_64F, Size(W, W));	// Jxy = imgDiffXYsmooth

    Mat tmp1, tmp2, tmp3, tmp4;
    tmp1 = imgDiffXXsmooth + imgDiffYYsmooth;
    tmp2 = imgDiffXXsmooth - imgDiffYYsmooth;
    multiply(tmp2, tmp2, tmp2);
    multiply(imgDiffXYsmooth, imgDiffXYsmooth, tmp3);
    sqrt(tmp2 + 4.0 * tmp3, tmp4);

    Mat lambda1, lambda2;
    lambda1 = tmp1 + tmp4;		// biggest eigenvalue 
    lambda2 = tmp1 - tmp4;		// smallest eigenvalue
	// lambda1 = Jxx + Jyy + sqrt((Jxx-Jyy)^2 + 4Jxy^2)
	// lambda2 = Jxx + Jyy - sqrt((Jxx-Jyy)^2 + 4Jxy^2)
	// eigenvalue calculation (stop)

    // Coherency calculation (start)
    // Coherency = (lambda1 - lambda2)/(lambda1 + lambda2)) - measure of anisotropism
	// Coherency is anisotropy degree (consistency of local orientation)
    divide(lambda1 - lambda2, lambda1 + lambda2, imgCoherencyOut);
    // Coherency calculation (stop)

    // orientation calculation (start)
    // tan2Alpha = 2Jxy/(Jyy - Jxx)
    // Alpha = 0.5 atan2(2Jxy/(Jyy - Jxx))
    phase(imgDiffYYsmooth - imgDiffXXsmooth, 2.0*imgDiffXYsmooth, imgOrientationOut, true);
    imgOrientationOut = 0.5*imgOrientationOut;
    // orientation calculation (stop)

    double minVal, maxVal;
    minMaxLoc(imgCoherencyOut, &minVal, &maxVal);
    cout << "imgCoherencyOut minVal = " << minVal << ";    imgCoherencyOut maxVal = " << maxVal << endl;

    Scalar meanLambda1, meanLambda2;
    meanLambda1 = mean(lambda1);
    meanLambda2 = mean(lambda2);
    cout << "meanLambda1 = " << meanLambda1(0) << ";    meanLambda2 = " << meanLambda2(0) << endl;

    minMaxLoc(imgOrientationOut, &minVal, &maxVal);
    cout << "imgOrientationOut minVal = " << minVal << ";    imgOrientationOut maxVal = " << maxVal << endl;
    cout << endl;
}

int main()
{
    namedWindow("imgOriginal", WINDOW_NORMAL);
    namedWindow("Coherency", WINDOW_NORMAL);
    namedWindow("Orientation", WINDOW_NORMAL);
    namedWindow("OrientationBinary", WINDOW_NORMAL);
    namedWindow("CoherencyBinary", WINDOW_NORMAL);
    namedWindow("Mask", WINDOW_NORMAL);
    namedWindow("control", WINDOW_NORMAL);

    //Create track bar for W
    int W = 52;
    createTrackbar("W", "control", &W, 100);
    cvSetTrackbarMin("W", "control", 1);

    //Create track bar for thr
    int C_Thr = 43;
    createTrackbar("0.01*C_Thr", "control", &C_Thr, 100);
    cvSetTrackbarMin("0.01*C_Thr", "control", 0);

    //Create track bar for Orientation thr
    int LowThr = 35;
    int HighThr = 57;
    createTrackbar("LowThr", "control", &LowThr, 180);
    createTrackbar("HighThr", "control", &HighThr, 180);

    //Mat imgOriginal = imread("D:\\home\\programming\\vc\\new\\6_My home projects\\4_GST\\input\\6.bmp");
    Mat imgOriginal = imread("D:\\home\\programming\\vc\\new\\6_My home projects\\4_GST\\input\\segm1.bmp");
	//Mat imgOriginal = imread("D:\\home\\programming\\vc\\new\\6_My home projects\\4_GST\\input\\7.bmp");
    
    Mat imgGray;
    cvtColor(imgOriginal, imgGray, COLOR_BGR2GRAY);

    while (true)
    {
        Mat imgCoherency, imgOrientation;
        calcGST(imgGray, imgCoherency, imgOrientation, W);

        Mat imgCoherencyBin;
        imgCoherencyBin = imgCoherency > C_Thr / 100.0;
        //threshold(imgCoherency, imgCoherencyBin, C_Thr/100.0, 255, THRESH_BINARY);	//dst	output array of the same size and type and the same number of channels as src.

        Mat imgOrientationBin;
        inRange(imgOrientation, Scalar(LowThr), Scalar(HighThr), imgOrientationBin);

        Mat imgBin;
        imgBin = imgCoherencyBin & imgOrientationBin;

        normalize(imgCoherency, imgCoherency, 0, 1, NORM_MINMAX);
        normalize(imgOrientation, imgOrientation, 0, 1, NORM_MINMAX);
        imshow("imgOriginal", 0.5*(imgGray + imgBin));
        imshow("Coherency", imgCoherency);
        imshow("Orientation", imgOrientation);
        imshow("CoherencyBinary", imgCoherencyBin);
        imshow("OrientationBinary", imgOrientationBin);
        imshow("Mask", imgBin);

        // Wait until user press some key for 50ms
        int iKey = waitKey(50);
        //if user press 'ESC' key
        if (iKey == 27)
        {
			imwrite("input.jpg", imgGray);
			imwrite("result.jpg", 0.5*(imgGray + imgBin));
            break;
        }
    }
    return 0;
}