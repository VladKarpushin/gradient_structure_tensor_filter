%����������� �� ���� ��������
% !!!!!!!!!!!�������� ��������� �� (-180:180)
%             ������� ��������� � ���������� ����������� � SegmAngle
function [bSegmAngle] = SegmAngle(InImg,Angle,dAngle)
%Angle - ���� � ��������
%dAngle - �������� ����� ��� ����������� �� ����(� ���� �������, � �������
%�� C++)
%InImg - ������ �����

AnglMax = Angle+dAngle;
AnglMin = Angle-dAngle;
AnglMax = AnglMax -(AnglMax>180)*360;
AnglMin = AnglMin +(AnglMin<(-180))*360;

if AnglMin < AnglMax
    bSegmAngle = (InImg>=AnglMin) & (InImg<AnglMax);
else
    bSegmAngle = ((InImg>=AnglMin) & (InImg<180)) | ((InImg>=-180) & (InImg<AnglMax));
end