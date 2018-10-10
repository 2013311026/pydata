function [ndat,norms] = normaliz(dat);
%NORMALIZ Normalizes rows of matrix to unit vectors
%  This function can be used for pattern normalization, which
%  is useful for preprocessing in some pattern recognition 
%  applications. The input is the data matrix (dat). The
%  output is the matrix of normalized data (ndat) and the
%  vector of norms used in the normalization (norms).
%  Warnings are given for any zero vectors found.
%
%I/O: [ndat,norms] = normaliz(dat);
%
%See also: AUTO, BASELINE, MNCN

%Copyright Eigenvector Research, Inc. 1997-98
%bmw May 30, 1997

[m,n] = size(dat);
ndat = dat;
norms = zeros(m,1);
for i = 1:m
  if norm(ndat(i,:)) ~= 0
    norms(i) = norm(ndat(i,:));
    ndat(i,:) = ndat(i,:)/norms(i);
  else
    disp(sprintf('The norm of sample %g is 0, sample not normalized!',i))
  end
end
  
