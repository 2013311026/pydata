function [xvec] = unfoldr(xmat);
%UNFOLDR unfolds a matrix to a vector for MPCA.
%  UNFOLDR unfolds the input matrix (xmat) to a row vector
%  (xvec) for MPCA. Each column of (xmat) is transposed and
%  augmented to create a vector (xvec). Example: For an
%  M by N input matrix A each M by 1 column ai is transposed
%  and augmented such that [xvec] = [a1',a2',...,aN']. 
%
%I/O: [xvec] = unfoldr(xmat);
%
%See Also: UNFOLDM, REFOLDR

%Copyright Eigenvector Research, Inc. 1996-98

[m,n] = size(xmat);
xvec  = zeros(1,m*n);
for ii=1:n
  jj         = [(ii-1)*m+1:ii*m];
  xvec(1,jj) = xmat(:,ii)';
end

