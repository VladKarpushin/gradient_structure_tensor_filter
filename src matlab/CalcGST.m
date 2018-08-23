%��������� ��� ���� �����������. 1 - ������������ ����, 0 - ����������
%�������� ��������� �����
%������ � �������������� �������������
%������ ���� �����������
function [StatSegment1,StatSegment2,StatSegment3,AngGr] = CalcGST(imp,SizeRad,method)

[sizeImgA,sizeImgB]=size(imp);               %������� �����������
win=SizeRad*2+1;

% GST components calculation (start)
switch method
   case {'msobel'}
     dimgX = SobelX(imp);%����������� �� X ������� 
     dimgY = SobelY(imp);%����������� �� Y ������� 
 otherwise
             error('����������� ����� �����');
end
dimgXY=dimgX.*dimgY;                        % Kxy
dimgX=dimgX.*dimgX;                         % Dx
dimgY=dimgY.*dimgY;                         % Dy
J11=sglad2(dimgX,win);                      % ����������
J22=sglad2(dimgY,win);                      % ����������
J12=sglad2(dimgXY,win);                     % ����������
% GST components calculation (stop)


% orientation angle calculation (start)
% tan(2*Alpha) = 2*J12/(J22 - J11)
% Alpha = 0.5 atan2(2*J12/(J22 - J11))
sizeIm=size(imp);                           %���������� �������
Angl=zeros(sizeIm);
Angl=(0.5*atan2(2*J12,(J22-J11)));          %��������� ����
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
 % orientation angle calculation (stop)

% eigenvalue calculation (start)
% lambda1 = J11 + J22 + sqrt((J11-J22)^2 + 4*J12^2)
% lambda2 = J11 + J22 - sqrt((J11-J22)^2 + 4*J12^2)
minD=((J22-J11).^2+4*J12.^2).^0.5;
lambda1 = J11 + J22 + minD; %������������ ����������� �����
lambda2 = J11 + J22 - minD; %����������� ����������� �����
% eigenvalue calculation (stop)

% Coherency calculation (start)
% Coherency2 = (lambda1 - lambda2)/(lambda1 + lambda2)) - measure of anisotropism
% Coherency is anisotropy degree (consistency of local orientation)
StatSegment1=1-lambda2./lambda1;%��������� ����������1
StatSegment1=StatSegment1(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����
StatSegment2=(lambda1 - lambda2)./(lambda1+lambda2);%��������� ����������2
StatSegment2=StatSegment2(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����
StatSegment3=(lambda1 - lambda2)./(lambda1+lambda2);%��������� ����������3
StatSegment3 = StatSegment3.^2;
StatSegment3=StatSegment3(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%�������� ����
% Coherency calculation (stop)