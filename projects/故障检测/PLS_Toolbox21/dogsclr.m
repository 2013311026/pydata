function [gys] = dogsclr(yin,vars,mxs,stdxs)
%DOGSCLR applies group scaling to submatrices of a matrix.
%  DOGSCLR group scales submatrices of a data matrix (yin).
%  Inputs are the number of variables (vars), a rowvector 
%  of means (mxs), and a row vector of standard deviations
%  (stdxs) that are output by the DOGSCL function. The output
%  is a group scaled matrix (gys). A typical application
%  is to scale a matrix unfolded for MPCA.
%
%I/O:  [gys] = dogsclr(yin,vars,mxs,stdxs);
%
%See Also: AUTO, GSCALE, GSCALER, DOGSCL, UNFOLDM

%Copyright Eigenvector Research, Inc. 1996-98

[m,nt]   = size(yin);
gys      = zeros(m,nt);
nt       = nt/vars;

for i = 1:vars
  j      = [(i-1)*nt+1:i*nt];
  [gys(:,j)] = gscaler(yin(:,j),mxs(1,j),stdxs(1,j));
end
