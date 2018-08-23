%��������� ��� ���� �����������. 1 - ������������ ����, 0 - ����������
function [StatSegment1,StatSegment2,StatSegment3,AngGr] = CalcGST(imp,SizeRad,method)
%�������� ��������� �����
%������ � �������������� �������������
%������ ���� �����������

[sizeImgA,sizeImgB]=size(imp);               %������� �����������
win=SizeRad*2+1;
switch method
   case {'msobel'}
     dimgX = SobelX(imp);%����������� �� X ������� 
     dimgY = SobelY(imp);%����������� �� Y ������� 
 otherwise
             error('����������� ����� �����');
end

dimgXY=dimgX.*dimgY;                        % Kxy
dimgX=dimgX.*dimgX;                         %Dx
dimgY=dimgY.*dimgY;                         %Dy
dimgX=sglad2(dimgX,win);                    %����������
dimgY=sglad2(dimgY,win);                    %����������
dimgXY=sglad2(dimgXY,win);                  %����������
sizeIm=size(imp);                           %���������� �������
Angl=zeros(sizeIm);
Angl=(0.5*atan2(2*dimgXY,(dimgY-dimgX)));   %��������� ����
SizeRad = SizeRad+1;                        %�������� ���� + 1
%SizeRad = 0;
Angl=Angl(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����
AngGr=Angl*180/pi;
%������������ �������� ����� 90 ���� � -90 ����
%�������� ��������� -90:90 ����
xx=-90:90;
[tmp,maxd]=max(hist(AngGr(:),xx));                %�������� ������������� ����� ��������
xmax=xx(maxd);
 if (xmax>45)
     AngGr=AngGr+(AngGr<-45)*180;                   %���������� ����� ������
 elseif (xmax<-45)
     AngGr=AngGr-(AngGr>45)*180;                    %���������� ����� �����
 end;

%��������� ���������� �� ����������� (�)
minD=((dimgY-dimgX).^2+4*dimgXY.^2).^0.5;
lambda1 = dimgY+dimgX+minD; %������������ ����������� �����
lambda2 = dimgY+dimgX-minD; %����������� ����������� �����

StatSegment1=1-lambda2./lambda1;%��������� ����������1
StatSegment1=StatSegment1(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����

StatSegment2=(lambda1 - lambda2)./(lambda1+lambda2);%��������� ����������2
StatSegment2=StatSegment2(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����

StatSegment3=(lambda1 - lambda2)./(lambda1+lambda2);%��������� ����������3
StatSegment3 = StatSegment3.^2;
StatSegment3=StatSegment3(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����
%��������� ���������� �� ����������� (�)