%вычисляет три вида сегментации. 1 - анизотропное поле, 0 - изотропное
function [StatSegment1,StatSegment2,StatSegment3,AngGr] = CalcGST(imp,SizeRad,method)
%исправил образание краев
%работа с прямоугольными изображениями
%оценка угла анизотропии

[sizeImgA,sizeImgB]=size(imp);               %размеры изображения
win=SizeRad*2+1;
switch method
   case {'msobel'}
     dimgX = SobelX(imp);%производная по X методом 
     dimgY = SobelY(imp);%производная по Y методом 
 otherwise
             error('неправильно задан метод');
end

dimgXY=dimgX.*dimgY;                        % Kxy
dimgX=dimgX.*dimgX;                         %Dx
dimgY=dimgY.*dimgY;                         %Dy
dimgX=sglad2(dimgX,win);                    %сглаживаем
dimgY=sglad2(dimgY,win);                    %сглаживаем
dimgXY=sglad2(dimgXY,win);                  %сглаживаем
sizeIm=size(imp);                           %Определяем размеры
Angl=zeros(sizeIm);
Angl=(0.5*atan2(2*dimgXY,(dimgY-dimgX)));   %вычисляем угол
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

%вычисляем статистику по анизотропии (н)
minD=((dimgY-dimgX).^2+4*dimgXY.^2).^0.5;
lambda1 = dimgY+dimgX+minD; %максимальное собственное число
lambda2 = dimgY+dimgX-minD; %минимальное собственное число

StatSegment1=1-lambda2./lambda1;%вычисляем статистику1
StatSegment1=StatSegment1(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края

StatSegment2=(lambda1 - lambda2)./(lambda1+lambda2);%вычисляем статистику2
StatSegment2=StatSegment2(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края

StatSegment3=(lambda1 - lambda2)./(lambda1+lambda2);%вычисляем статистику3
StatSegment3 = StatSegment3.^2;
StatSegment3=StatSegment3(1+SizeRad:sizeImgA-SizeRad,1+SizeRad:sizeImgB-SizeRad);%обрезаем края
%вычисляем статистику по анизотропии (к)