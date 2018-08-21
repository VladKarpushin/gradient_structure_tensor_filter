%сегментация по углу поворота
% !!!!!!!!!!!Диапазон изменения ПН (-180:180)
%             внесены изменения в вычисление гистограммы и SegmAngle
function [bSegmAngle] = SegmAngle(InImg,Angle,dAngle)
%Angle - угол в градусах
%dAngle - диапазон углов для сегментации по углу(в одну сторону, в отличии
%от C++)
%InImg - массив углов

AnglMax = Angle+dAngle;
AnglMin = Angle-dAngle;
AnglMax = AnglMax -(AnglMax>180)*360;
AnglMin = AnglMin +(AnglMin<(-180))*360;

if AnglMin < AnglMax
    bSegmAngle = (InImg>=AnglMin) & (InImg<AnglMax);
else
    bSegmAngle = ((InImg>=AnglMin) & (InImg<180)) | ((InImg>=-180) & (InImg<AnglMax));
end