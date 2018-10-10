function [gxs,mxs,stdxs] = dogscl(xin,vars)
%DOGSCL Performs group/block scaling to submatrices of a single matrix.
%  DOGSCL is useful when it is desired to group scale submatrices
%  of a single data matrix as in MPCA. Inputs are a matrix (xin)
%  and the number of variables (vars). Outputs are the scaled
%  matrix (gxs), a rowvector of means (mxs), and a row vector
%  of standard deviations (stdxs). For example, xin = [A1,A2,...
%  ,Avars]. Each of the Ai is m by nt where m is the number of
%  samples and nt (for example) is the number of time steps in a
%  batch operation. Each submatrix Ai is group scaled to zero mean
%  and total variance 1. If xin is m by n and vars = n then DOGSCL
%  is equivalent to AUTO.
%
%I/O:  [gxs,mxs,stdxs] = dogscl(xin,vars);
%
%See Also: AUTO, GSCALE, GSCALER, DOGSCLR, UNFOLDM

%Copyright Eigenvector Research, Inc. 1996-98


[m,nt]   = size(xin);
gxs      = zeros(m,nt);
mxs      = zeros(1,nt);
stdxs    = mxs;
nt       = nt/vars;

for i = 1:vars
  j      = [(i-1)*nt+1:i*nt];
  [gxs(:,j),mxs(1,j),stdxs(1,j)] = gscale(xin(:,j));
end
