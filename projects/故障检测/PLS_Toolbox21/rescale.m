function rx = rescale(x,mx,stdx)
%RESCALE Rescales matrix 
%  Rescales a matrix (x) using the means (mx) and
%  standard deviation (stdx) vectors specified.
%
%I/O: rx = rescale(x,mx,stdx);
%
%  If only two input arguments are supplied the
%  function rescales the means only.
%
%I/O: rx = rescale(x,mx);
%
%See also:  AUTO, MDAUTO, MDMNCN, MDRESCAL, MDSCALE, MNCN, SCALE

%Copyright Eigenvector Research, Inc. 1991-98
%Modified 11/93
%Checked on MATLAB 5 by BMW  1/4/97

[m,n] = size(x);
if nargin == 3
  rx  = (x.*stdx(ones(m,1),:))+mx(ones(m,1),:);
else
  rx  = x+mx(ones(m,1),:);
end
