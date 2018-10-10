function ypred = lwrpred(xnew,xold,yold,lvs,npts,out)
%LWRPRED Predictions based on locally weighted regression models
%  This function makes new sample predictions (ypred) for a new
%  matrix of independent variables (xnew) based on an existing 
%  data set of independent (xold) and a vector of dependent
%  variables (yold). Predictions are made using a locally weighted
%  regression model defined by the number principal components
%  used to model the independent variables (lvs), and the number
%  of points defined as local (npts). The optional input (out)
%  suppresses printing of the results when set to 0 {default = 1}.
%
%Note:  Be sure to use the same scaling on new and old samples!
%
%I/O: ypred = lwrpred(xnew,xold,yold,lvs,npts,out);
%
%See also: LWRDEMO, LWRXY, NNPLS, PLS, POLYPLS, SPL_PLS

%Copyright Eigenvector Research 1994-2000
%Modified BMW 2/94
%nbg 11/00 added out

if nargin<6    %nbg 11/00
  out = 1;
end
if lvs > npts
  error('npts must >= lvs')
end
[m,n] = size(xnew);
[mold,nold] = size(xold);
if n ~= nold
  error('xnew and xold must have the same number of columns')
end
[axold,mxold,stdxold] = auto(xold);
[ayold,myold,stdyold] = auto(yold);
[u,s,v] = svd(axold,0);
[au,umx,ustd] = auto(u(:,1:lvs)*s(1:lvs,1:lvs));
[mau,nau] = size(au);
sxnew = scale(xnew,mxold,stdxold);
newu = scale(sxnew*v(:,1:lvs),umx,ustd);
ureg = zeros(npts,lvs);
yreg = zeros(npts,1);
weights = zeros(npts,1);
ypred = zeros(m,1);
%clc                   %nbg 11/00
for i = 1:m;
  %home                %nbg 11/00
  if out~=0
    disp(sprintf('Now working on sample %g of %g.',i,m))
  end
  %dists = sum(((au-ones(mau,nau)*diag(newu(i,:))).^2)')';
  dists = sum(((au-ones(mau,nau)*diag(newu(i,:))).^2)',1)';
  [a,b] = sort(dists);
  for j = 1:npts
    ureg(j,:) = au(b(j,1),:);
    yreg(j,:) = ayold(b(j,1),1);
    scldist = a(j,1)/a(npts,1);
    weights(j,:) = (1 - scldist^3)^3;
  end
  h = diag(weights.^2);
  ureg1 = [ureg ones(npts,1)];
  breg = inv(ureg1'*h*ureg1)*ureg1'*h*yreg;
  sypred(i,1) = [newu(i,:) 1]*breg;
end
ypred = rescale(sypred,myold,stdyold);
