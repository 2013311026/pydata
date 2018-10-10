function [gx] = gscaler(newdata,mx,stdx)
%GSCALER group scales a new matrix.
%  GSCALER scales a matrix (newdata) using a vector
%  of means (mx) and a vector of standard deviations
%  (stdx), and returns the resulting matrix (gx).
%  (mx) is subtracted from each row of newdata the result
%  is divided by sqrt(sum(stdx.^2)). GSCALER is typically
%  used to scale new MPCA data to the mean and variance
%  of previously analyzed MPCA data.
%
%I/O:  [gx] = gscaler(newdata,mx,stdx);
%
%See Also: GSCALE, DOGSCL, DOGSCLR, RESCALE, SCALE

%Copyright Eigenvector Research, Inc. 1996-98

[m,n] = size(newdata);
stdt  = stdx.^2;
stdt  = sqrt(sum(stdt));
gx    = (newdata-mx(ones(m,1),:))/stdt;

