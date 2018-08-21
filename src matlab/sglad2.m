function Y = sglad2(Imp,n)
% сглаживание квадратным окном n*n
Shimp=ones(n);%квадратная матрица с единичными весами
  Y = filter2(Shimp,Imp,'same')/(n*n);%сглаживание
%  Y = filter2(Shimp,Imp,'valid');%сглаживание
