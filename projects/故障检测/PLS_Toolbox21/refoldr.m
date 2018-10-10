function [ymat] = refoldr(yvec,nvar);
%REFOLDR refolds a vector from MPCA to a matrix.
%  REFOLDR refolds a row vector (yvec) to a matrix (ymat). A
%  typical (yvec) is a loadings vector from MPCA which contains
%  (nvar) augmented vectors. (nvar) is the number of variables
%  in (xmat) unfolded by UNFOLDR. Example: For the unfolded row
%  vector [yvec] = [a1',a2',...,anvar'] the corresponding folded
%  matrix is [ymat] = [a1,a2,...,anvar].
%
%I/O: ymat = refoldr(yvec,nvar);
%
%See also: UNFOLDM, UNFOLDR

%Copyright Eigenvector Research, Inc. 1996-98
%Modified 10/96 NBG

[m,n]   = size(yvec);
if (m>1)&(n>1)
  error('input must be a vector')
end

if m>1
  yvec  = yvec';
  s     = m;
  m     = n;
  n     = s;
end

m       = n/nvar;
if (m-round(m))~=0
  error('length of yvec not evenly divisible by nvar')
else
  ymat  = zeros(m,nvar);
  for ii=1:nvar
    jj         = [(ii-1)*m+1:ii*m];
    ymat(:,ii) = yvec(:,jj)';
  end
end

