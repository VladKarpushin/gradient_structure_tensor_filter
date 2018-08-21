% 2018-02-05
% Segmentation based on Gradient structure tensor (GST)

close all,clc,clear all;

strFolder = 'D:\home\programming\vc\new\6_My home projects\4_GST\input\';
strFileName = strcat(strFolder,'segm1.bmp');

%****************************
%*****  input image  ********
%****************************

img = imread(strFileName);

if size(img,3)==3
    img = rgb2gray(img);    
end

SizeRad = 21;

%****************************
%*****GST calculation********
%****************************

[StatSegment1, StatSegment2, StatSegment3, AngGr] = CalcGST(img, SizeRad, 'msobel');
imgBin = StatSegment2 > 0.55;

%*******************
%*****Output********
%*******************

figure, 
subplot(2,3,1);
imshow(img);
title('original');

subplot(2,3,2);
imshow(StatSegment1,[]);
title('StatSegment1=1-lambda2./lambda1');

subplot(2,3,3);
imshow(StatSegment2,[]);
title('StatSegment2=(lambda1 - lambda2)./(lambda1+lambda2)');

subplot(2,3,4);
imshow(StatSegment3,[]);
title('StatSegment3=((lambda1 - lambda2)./(lambda1+lambda2))^2');

subplot(2,3,5);
imshow(imgBin,[]);
title('imgBin');

subplot(2,3,6);
imshow(AngGr,[]);
title('Angle');