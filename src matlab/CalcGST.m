%вычисляет три вида сегментации. 1 - анизотропное поле, 0 - изотропное
%исправил образание краев
%работа с прямоугольными изображениями
%оценка угла анизотропии
function [StatSegment1,StatSegment2,StatSegment3,AngGr] = CalcGST(imp,SizeRad,method)

[sizeImgA,sizeImgB]=size(imp);               %размеры изображения
win=SizeRad*2+1;

% GST components calculation (start)
switch method
   case {'msobel'}
     dimgX = SobelX(imp);%производная по X методом 
     dimgY = SobelY(imp);%производная по Y методом 
 otherwise
             error('неправильно задан метод');
end
dimgXY=dimgX.*dimgY;                        % Kxy
dimgX=dimgX.*dimgX;                         % Dx
dimgY=dimgY.*dimgY;                         % Dy
J11=sglad2(dimgX,win);                      % сглаживаем
J22=sglad2(dimgY,win);                      % сглаживаем
J12=sglad2(dimgXY,win);                     % сглаживаем
% GST components calculation (stop)


% orientation angle calculation (start)
% tan(2*Alpha) = 2*J12/(J22 - J11)
% Alpha = 0.5 atan2(2*J12/(J22 - J11))
sizeIm=size(imp);                           %Определяем размеры
Angl=zeros(sizeIm);
Angl=(0.5*atan2(2*J12,(J22-J11)));          %вычисляем угол
SizeRad = SizeRad+1;                        %половина окна + 1
%SizeRad = 0;
Angl=Angl(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края
AngGr=Angl*180/pi;
%корректируем перескок через 90 град и -90 град
%диапазон изменений -90:90 град
xx=-90:90;
[tmp,maxd]=max(hist(AngGr(:),xx));                %значение максимального числа отсчетов
xmax=xx(maxd);
 if (xmax>45)
     AngGr=AngGr+(AngGr<-45)*180;                   %перемещаем хвост вправо
 elseif (xmax<-45)
     AngGr=AngGr-(AngGr>45)*180;                    %перемещаем хвост влево
 end;
 % orientation angle calculation (stop)

% eigenvalue calculation (start)
% lambda1 = J11 + J22 + sqrt((J11-J22)^2 + 4*J12^2)
% lambda2 = J11 + J22 - sqrt((J11-J22)^2 + 4*J12^2)
minD=((J22-J11).^2+4*J12.^2).^0.5;
lambda1 = J11 + J22 + minD; %максимальное собственное число
lambda2 = J11 + J22 - minD; %минимальное собственное число
% eigenvalue calculation (stop)

% Coherency calculation (start)
% Coherency2 = (lambda1 - lambda2)/(lambda1 + lambda2)) - measure of anisotropism
% Coherency is anisotropy degree (consistency of local orientation)
StatSegment1=1-lambda2./lambda1;%вычисляем статистику1
StatSegment1=StatSegment1(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края
StatSegment2=(lambda1 - lambda2)./(lambda1+lambda2);%вычисляем статистику2
StatSegment2=StatSegment2(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края
StatSegment3=(lambda1 - lambda2)./(lambda1+lambda2);%вычисляем статистику3
StatSegment3 = StatSegment3.^2;
StatSegment3=StatSegment3(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края
% Coherency calculation (stop)