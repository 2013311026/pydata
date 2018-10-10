function vc = varcap(x,loads,scl,plots);
%VARCAP Variance captured for each variable in PCA model
%  Calculates percent variance captured in a PCA model for each
%  variable and number of PCs. Inputs are the properly scaled
%  data (x) [mxn], and the associated loadings matrix (loads) [nxk].
%  Optional inputs are (scl) [1xn] which specifies the x-axis for
%  plotting, and (plots) which suppresses plotting when set to 0.
%  The output is a matrix of % variance captured (vc) [nxk] for each
%  variable on each PC in the PCA model (vc is number of PCs by
%  number of variables).
%
%I/O: vc = varcap(x,loads,scl,plots);
%
%See also: PCA, PCAGUI

%Copyright Eigenvector Research, Inc. 1997-2000
%bmw
%nbg 5/00 plots

[mx,nx]   = size(x);
if nargin<3
  scl     = 1:nx;
  mnscl   = 0;
  mxscl   = nx+1;
elseif isempty(scl)
  scl     = 1:size(x,2);
  mnscl   = 0;
  mxscl   = nx+1;
elseif length(scl)~=size(x,2);
  scl     = 1:size(x,2);
  mnscl   = 0;
  mxscl   = nx+1;
else
  mnscl   = min(scl)-(max(scl)-min(scl))/nx;
  mxscl   = max(scl)+(max(scl)-min(scl))/nx;
end
if nargin<4
  plots   = 1;
end

tssq      = sum(x.^2);
[mx,nl]   = size(loads);
vc        = zeros(nl,nx);
for i=1:nl
  pcaest  = x*loads(:,i)*loads(:,i)';
  vc(i,:) = 100*sum(pcaest.^2)./tssq;
end
size(scl), size(vc')
if plots~=0
  bar(scl,vc','stacked')
  axis([mnscl mxscl 0 100])
  set(get(gca,'Children'),'linestyle','none')
  xlabel('Variable')
  ylabel('Percent Variance Captured')
  title(sprintf('Variance Captured for %g PC Model',nl))
end