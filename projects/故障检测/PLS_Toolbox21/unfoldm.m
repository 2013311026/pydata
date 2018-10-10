function [xmpca] = unfoldm(xaug,nsamp);
%UNFOLDM unfolds an augmented matrix for MPCA
%  UNFOLDM unfolds the input matrix (xaug) to create a
%  matrix of unfolded row vectors (xmpca) for MPCA. (xaug)
%  contains (nsamp) matrices Aj augmented such that
%  [xaug] = [A1;A2;...;Ansamp]. For example, for (xaug) of
%  size (Nsamp*M by N) each matrix Aj is of size M by N. For
%  Aj each Mx1 column ai is transposed and augmented such that
%  [bj] = [a1',a2',...,aN'] and [xmpca] = [b1;b2;...;bnsamp].
%  Note: the Aj should all be the same size.
%
%I/O: xmpca = unfoldm(xaug,nsamp);
%
%See Also: UNFOLDR, REFOLDR

%Copyright Eigenvector Research, Inc. 1996-98
%Modified 10/96 NBG

[m,n]   = size(xaug);
mm       = m/nsamp;
if (mm-round(mm))~=0
  error('number of rows of xaug not evenly divisible by number of samples')
else
  xmpca = zeros(nsamp,mm*n);
  for ii=1:mm
    xmpca(:,ii:mm:mm*n) = xaug(ii:mm:m,:);
  end
end

