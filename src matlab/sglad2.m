function Y = sglad2(Imp,n)
% ����������� ���������� ����� n*n
Shimp=ones(n);%���������� ������� � ���������� ������
  Y = filter2(Shimp,Imp,'same')/(n*n);%�����������
%  Y = filter2(Shimp,Imp,'valid');%�����������
