function [resmat,res] = resmtx(x,p)
%RESMTX calculates the residuals contributions for PCA
%RESMTX calculates E from the PCA model X = TP'+E
%  Given the inputs of the data matrix (x) and the
%  PCA loadings (p) RESMTX calculates the
%  residuals matrix (resmat) as E = X(I-PP') where
%  resmat = E and the Q residuals (res).
%
%I/O: [resmat,res] = resmtx(x,p);
%  
%  Note: The data matrix (x) must be scaled in a similar
%  manner to the data used to determine the loadings (p).
%
%See also: PCA, PCAPRO, TSQMTX

%Copyright Eigenvector Research, Inc. 1996-98

[mx,nx]  = size(x);
[mp,np]  = size(p);
if mp ~= nx
  error('Size of x and p not compatible')
end
resmat = x*p;
resmat = resmat*p';
resmat = x - resmat;
res    = sum((resmat.^2)')';
