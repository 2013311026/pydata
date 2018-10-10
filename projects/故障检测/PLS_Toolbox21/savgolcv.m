function [cumpress] = savgolcv(x,y,lv,width,order,deriv,ind,rm,cvm,split,iter,mc)
%SAVGOLCV Cross-validation for Savitsky-Golay smoothing and differentiation.
%  SAVGOLCV performs cross validation of Savitsky-Golay parameters
%  filter width, polynomial order, and derviative order.
%  INPUT:
%    x     = (m by n) matrix of predictor variables with ROW 
%            vectors to be smoothed (e.g. spectra).
%    y     = (m by p) matrix of predicted variables.
%    ind   = indices of columns of x to use for calibration
%            {default = [1:n] i.e. all x columns}. In some cases
%            fewer channels are used for calibration. These channels
%            are given in the vector (ind). SAVGOLCV uses all channels
%            for smoothing/derivitizing but only the (ind) channels in
%            the cross-validation/prediction.
%
%  SAVITSKY-GOLAY PARAMETERS (calls SAVGOL)
%    The following variables are cross validated by entering 
%    a vector instead of a scalar.
%    width = number of points in filter {default = [11 17 23]}.
%    order = polynomial order {default = [2 3]}.
%    deriv = derivative order {default = [0 1 2]}.
%
%  CROSS-VALIDATION METHOD (calls CROSSVAL)
%    lv    = number of latent variables {default = min(size(x))}.
%    rm    = regression method. Options are:
%      'nip'  = PLS via NIPALS algorithm,
%      'sim'  = PLS via SIMPLS algorithm {default}, and
%      'pcr'  = PCR.
%    cvm   = cross validation method. Options are:
%      'loo'  = leave-one-out,
%      'vet'  = venetian blinds {default},
%      'con'  = contiguous blocks, and
%      'rnd'  = repeated random test sets.
%    split = number of subsets to split the data into {default = 5}
%              (needed for cvm = 'vet', 'con', or 'rnd').
%    iter  = number of iterations {default = 5} (needed for cvm = 'rnd').
%    mc    = supresses mean centering of subsets when set to 0.
%
%  OUTPUT:
%    cumpress(i,:,:,:) = deriv;
%    cumpress(:,j,:,:) = lv;
%    cumpress(:,:,k,:) = width;
%    cumpress(:,:,:,l) = order;
%
%I/O: cumpress = savgolcv(x,y,lv,width,order,deriv,ind,rm,cvm,split,iter,mc);
% 
%See also: BASELINE, CROSSVAL, LAMSEL, MSCORR, SAVGOL, SGDEMO, SPECEDIT, STDFIR

%Copyright Eigenvector Research, Inc. 1997-99
%nbg 3/24/99

if isempty(x)|isempty(y)
  error('x or y is empty')
end
if exist('lv')~=1
  lv   = min(size(x));
elseif isempty(lv)
  lv   = min(size(x));
end
if lv>min(size(x))
  lv   = min(size(x));
end
if exist('width')~=1
  width = [11 17 23];
elseif isempty(width)
  width = [11 17 23];
end
if exist('order')~=1
  order = [2 3];
elseif isempty(order)
  order = [2 3];
end
if exist('deriv')~=1
  deriv = [0 1 2];
elseif isempty(deriv)
  deriv = [0 1 2];
end
if exist('ind')~=1
  ind   = [1:size(x,2)];
elseif isempty(ind)
  ind   = [1:size(x,2)];
end
if exist('rm')~=1
  rm    = 'sim';
elseif isempty(rm)
  rm    = 'sim';
end
if exist('cvm')~=1
  cvm   = 'vet';
elseif isempty(cvm)
  cvm   = 'vet';
end
if exist('split')~=1
  split = 5;
elseif isempty(split)
  split = 5;
end
if exist('iter')~=1
  iter  = 5;
elseif isempty(iter)
  iter = 5;
end

cumpress = zeros(length(deriv),lv,length(width),length(order));

for i1=1:length(deriv)
  for i2 = 1:length(width);
    for i3 = 1:length(order);
      xh = savgol(x,width(i2),order(i3),deriv(i1));
      [ps,cumpress(i1,[1:lv],i2,i3)] = crossval(xh(:,ind),y, ...
        rm,cvm,lv,split,iter,1,0);
    end
  end
end
