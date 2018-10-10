function [egf,egr] = evolvfa(xdat,plots,tdat);
%EVOLVFA performs forward and reverse evolving factor analysis.
%  EVOLVFA calculates the singular values (square roots of
%  the eigenvalues of the covariance matrix) of sub-matrices of 
%  (xdat) and returns results of the forward analysis in (egf) and
%  reverse analysis in (egr). The optional input (plots) allows
%  the user to supress plotting the results, and the optional
%  input (tdat) is a vector to plot the results against.
%  plots = 0 suppresses plotting of results.
%
%I/O: [egf,egr] = evolvfa(xdat,plots,tdat);
%
%See also: EFA_DEMO, EWFA, PCA

%Copyright Eigenvector Research, Inc. 1995-98
%Modified BMW April 1998

[mx,nx] = size(xdat);
if nargin < 2
  plots  = 1;
end
if nargin < 3
  tdat  = [1:mx];
end
ydat    = xdat';
if mx > nx
  mmax  = nx;
else
  mmax  = mx;
end
egf     = zeros(mx,mmax);
egr     = zeros(mx,mmax);

for i=1:mx
  if i < nx
    zdat = ydat(:,1:i);
  else
    zdat = xdat(1:i,:);
  end
  s = svd(zdat,0);
  egf(i,1:min(i,mmax)) = s';
end
for i=mx:-1:1
  if mx-i+1 < nx
    zdat = ydat(:,i:mx);
  else
    zdat = xdat(i:mx,:);
  end
  s = svd(zdat,0);
  egr(i,1:min(mx-i+1,mmax)) = s';
end
clear s xdat ydat zdat

if plots ~= 0
  figure
  subplot(2,1,1)
  semilogy(tdat,egf,'-')
  ylabel('Singular Value')
  xlabel('Time')
  title('Forward Analysis')
  subplot(2,1,2)
  semilogy(tdat,egr,'-')
  ylabel('Singular Value')
  xlabel('Time')
  title('Reverse Analysis')
end

