function [tsqmat,tsqs] = tsqmtx(x,p,ssq);
%TSQMTX calculates matrix for T^2 contributions for PCA
%  Given a data matrix (x), loadings (p), and variance
%  table (ssq). TSQMTX calculates the matrix for indivual
%  variable contributions to Hotelling's T^2 (tsqmat) and
%  Hotelling's T^2 (tsqs). If s is the covariance matrix
%  then tsqmat = x*p*sqrt(inv(s))*p';
% 
%I/O: [tsqmat,tsqs] = tsqmtx(x,p,ssq);
%  
%  Note: The data matrix (x) must be scaled in a similar
%  manner to the data used to determine the loadings (p).
%
%See also: PCA, PCAPRO, RESMTX

%Copyright Eigenvector Research, Inc. 1996-98
%Modified: NBG 10/96,7/97

[mx,nx] = size(x);
[mp,np] = size(p);
if mp~=nx
  error('Size of x and p not compatible')
end
tsqmat  = x*p;
mp      = 1./sqrt(ssq(1:np,2));
tsqmat  = tsqmat*diag(mp);
if np>1
  tsqs  = sum((tsqmat.^2)')';
else
  tsqs  = tsqmat.^2;
end
tsqmat  = tsqmat*p';
