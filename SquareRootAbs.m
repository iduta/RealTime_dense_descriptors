function b = SquareRootAbs(a)
% out = SquareRootAbs(in)
%
% Does square root on all values in a, but keeps the signs
%
%           Jasper Uijlings - 2013

aNeg = ((a > 0) .* 2) - 1; % -1 is negative, 1 positive sign
b = sqrt(abs(a)); % Square root of absolute values
b = b .* aNeg; % Redo signs.