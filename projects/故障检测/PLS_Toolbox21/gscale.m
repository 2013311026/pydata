function [gx,mx,stdx] = gscale(x)
%GSCALE group scales a matrix.
%  GSCALE scales an input matrix (x) such that the columns
%  have mean zero and variance relative to the total
%  variance in (x). The output is the matrix (gx), a vector
%  of means (mx), and a vector of standard deviations (stdx)
%  used in the scaling.
%
%I/O:  [gx,mx,stdx] = gscale(x);
%
%See Also: AUTO, DOGSCL, DOGSCLR, GSCALER, MNCN

%Copyright Eigenvector Research, Inc. 1996-98

[m,n] = size(x);
mx    = mean(x);
stdx  = std(x);
stdt  = sqrt(sum(stdx.^2));
gx    = (x-mx(ones(m,1),:))/stdt;

