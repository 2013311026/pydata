function newx = oscapp(x,nw,np,nofact);
%OSCAPP Applies OSC model to new data
%  The inputs are the new data matrix (x), weights from the
%  OSC model (nw) and loadings from the OSC (np). An optional
%  input can be used to restrict the correction to the a smaller
%  of factors (nofact) than originally calculated. Output is
%  is the corrected data matrix (newx). Note: input data must
%  be centered and scaled like the original data!
%
%I/O: newx = oscapp(x,nw,np,nofact);
%
%See also: OSCCALC, CROSSVAL

%Copyright Eigenvector Research, Inc. 2000
%BMW 11/2000

[mx,nx] = size(x);
[mnw,nnw] = size(nw);
[mnp,nnp] = size(np);
if nargin < 4
  nofact = nnw;
end
if nx ~= mnw | nx ~= mnp
  error('Size of weights (nw) and/or loadings (np) not consistant with data (x)')
end
if nnw ~= nnp
  error('Loadings (np) and weights (nw) not for the same number of factors')
end
if nofact > nnw | nofact > nnp 
  error('Number of factors requested > number originally calculated')
end 
if nofact == nnw
  newx = x - x*nw*inv(np'*nw)*np';
else
  nw = nw(:,1:nofact);
  np = np(:,1:nofact);
  newx = x - x*nw*inv(np'*nw)*np';
end