function Y = mat_int(A,t1,t2)
%calculate the integral of the matrix exponential 

global  i1 i2

Y=zeros(size(A));

A=A;%this needs for running under PC

for i1=1:size(A)
	for i2=1:size(A)
		Y(i1,i2) = quad('matexp',t1,t2);

	end
end
