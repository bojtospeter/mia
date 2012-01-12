function Y= matexp(t)
%calculate the matrix exponent of X
global A i1 i2 

size_t=size(t);
Y=zeros(size(t));

for j=1:size_t(2)
	Z = expm(A*t(j));
	Y(j) = Z(i1,i2);
end
