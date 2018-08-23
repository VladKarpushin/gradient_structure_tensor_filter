% 2018-02-05
% Segmentation based on Gradient structure tensor (GST)
% @brief You will learn how to segment an image by Gradient structure tensor (GST)
% @author Karpushin Vladislav, karpushin@ngs.ru, https://github.com/VladKarpushin

close all,clc,clear all;

strFolder = 'D:\home\programming\vc\new\6_My home projects\4_GST\input\';
strFileName = strcat(strFolder,'segm1.bmp');
%strFileName = strcat(strFolder,'6.bmp');

%****************************
%*****  input image  ********
%****************************

img = imread(strFileName);

if size(img,3)==3
    img = rgb2gray(img);    
end

SizeRad = 25;       %radius

%****************************
%*****GST calculation********
%****************************

[imgCoherency1, imgCoherency2, imgCoherency3, imgOrientation] = CalcGST(img, SizeRad, 'msobel');
imgCoherencyBin = imgCoherency2 > 0.43;
imgOrientationBin = imgOrientation > 35 & imgOrientation < 57;
imgBin = imgCoherencyBin & imgOrientationBin;

%*******************
%*****Output********
%*******************

figure, 
subplot(2,4,1);
imshow(img);
title('original');

subplot(2,4,2);
imshow(imgCoherency1,[]);
title('C1=1-lambda2./lambda1');

subplot(2,4,3);
imshow(imgCoherency2,[]);
title('C2=(lambda1 - lambda2)./(lambda1+lambda2)');

subplot(2,4,4);
imshow(imgCoherency3,[]);
title('C3=((lambda1 - lambda2)./(lambda1+lambda2))^2');

subplot(2,4,5);
imshow(imgCoherencyBin,[]);
title('imgCoherencyBin');

subplot(2,4,6);
imshow(imgOrientation,[]);
title('Angle');

subplot(2,4,7);
imshow(imgBin,[]);
title('imgBin');