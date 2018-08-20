// 2018-02-04.
// Function calculates GST (gradient structure tensor)
// 2018-02-05
// fixed Gxy bug
// 2018-02-08
// added orientation estimation
// added orientation binarization

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

    Mat imgDiffX, imgDiffY, imgDiffXY;
    Sobel(img, imgDiffX, CV_64F, 1, 0, 3);
    Sobel(img, imgDiffY, CV_64F, 0, 1, 3);
    multiply(imgDiffX, imgDiffY, imgDiffXY);

    Mat imgDiffXX, imgDiffYY;
    multiply(imgDiffX, imgDiffX, imgDiffXX);	
    multiply(imgDiffY, imgDiffY, imgDiffYY);	

    Mat imgDiffXXsmooth, imgDiffYYsmooth, imgDiffXYsmooth;
    boxFilter(imgDiffXX, imgDiffXXsmooth, CV_64F, Size(W, W));	// Gxx = imgDiffXXsmooth
    boxFilter(imgDiffYY, imgDiffYYsmooth, CV_64F, Size(W, W));	// Gyy = imgDiffYYsmooth
    boxFilter(imgDiffXY, imgDiffXYsmooth, CV_64F, Size(W, W));	// Gxy = imgDiffXYsmooth

    Mat tmp1, tmp2, tmp3, tmp4;
    tmp1 = imgDiffXXsmooth + imgDiffYYsmooth;
    tmp2 = imgDiffXXsmooth - imgDiffYYsmooth;
    multiply(tmp2, tmp2, tmp2);
    multiply(imgDiffXYsmooth, imgDiffXYsmooth, tmp3);
    tmp3 = 4.0 * tmp3;
    tmp4 = tmp2 + tmp3;
    sqrt(tmp4, tmp4);

    Mat lambda1, lambda2;
    lambda1 = tmp1 + tmp4;
    lambda2 = tmp1 - tmp4;

    // Coherency calculation (start)
    // Coherency = (lambda1 - lambda2)/(lambda1 + lambda2))
    Mat imgCoherency;		
    absdiff(lambda1, lambda2, tmp1);
    divide(tmp1, lambda1 + lambda2, imgCoherency);
    // Coherency calculation (stop)

    // orientation calculation (start)
    // tan2Alpha = 2Gxy/(Gyy - Gxx)
    // Alpha = 0.5 atan2(2Gxy/(Gyy - Gxx))
    // tmp1 = (Gyy - Gxx);
    // tmp2 = 2Gxy
    Mat imgPhase;
    phase(imgDiffYYsmooth - imgDiffXXsmooth, 2.0*imgDiffXYsmooth, imgPhase, true);
    imgPhase = 0.5*imgPhase;
    // orientation calculation (stop)

    double minVal, maxVal;
    minMaxLoc(imgCoherency, &minVal, &maxVal);
    cout << "imgCoherency minVal = " << minVal << ";    imgCoherency maxVal = " << maxVal << endl;

    Scalar meanLambda1, meanLambda2;
    meanLambda1 = mean(lambda1);
    meanLambda2 = mean(lambda2);
    cout << "meanLambda1 = " << meanLambda1(0) << ";    meanLambda2 = " << meanLambda2(0) << endl;

    minMaxLoc(imgPhase, &minVal, &maxVal);
    cout << "imgPhase minVal = " << minVal << ";    imgPhase maxVal = " << maxVal << endl;
    cout << endl;

    imgCoherencyOut = imgCoherency;
    imgOrientationOut = imgPhase;
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
    int W = 17*2+1;
    createTrackbar("W", "control", &W, 100);
    cvSetTrackbarMin("W", "control", 1);

    //Create track bar for thr
    int C_Thr = 55;
    createTrackbar("0.01*C_Thr", "control", &C_Thr, 100);
    cvSetTrackbarMin("0.01*C_Thr", "control", 0);

    //Create track bar for Orientation thr
    int LowThr = 0;
    int HighThr = 180;
    createTrackbar("LowThr", "control", &LowThr, 180);
    createTrackbar("HighThr", "control", &HighThr, 180);

    Mat imgOriginal = imread("D:\\home\\programming\\vc\\new\\6_My home projects\\4_GST\\input\\6.bmp");
    //Mat imgOriginal = imread("D:\\home\\programming\\vc\\new\\6_My home projects\\4_GST\\input\\segm1.bmp");
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
            break;
        }
    }
    return 0;
}