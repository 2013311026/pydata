function model = mpca(mwa,scaling,nocomp)
%MPCA Multi-way Principal Components Analysis
%  Principal Components Analysis of multi-way data using
%  unfolding to a two way matrix followed by conventional
%  PCA. The inputs are the multi-way array (mwa), and the
%  optional inputs of scaling option to be used (scale), and the
%  number of components to be retained in the model (nocomp).
%
%  There are four scaling options as follows:
%   0 'none'  -  no scaling
%   1 'auto'  -  unfolds array then applies autoscaling
%   2 'mncn'  -  unfolds array then applies mean centering
%   3 'grps'  -  unfolds array then group scales each variable, i.e.
%                the same variance scaling is used for each variable
%                along its time trajectory (Default)
%
%  The ouput is a model in structured array format with
%  the following fields:
%
%     xname: name of the original workspace input variable
%      name: type of model, always 'MPCA'
%      date: model creation date stamp
%      time: model creation time stamp
%      size: size of the original input array
%    nocomp: number of components retained
%     scale: scaling option used
%     means: means (unfolded) used for scaling
%      stds: standard deviations (unfolded) used for scaling
%       ssq: sum of squares captured information
%    scores: sample scores
%     loads: loadings
%       res: sample Q residuals
%    reslim: 95% limit on sample residuals
%       tsq: sample T^2 values
%    tsqlim: 95% limit on T^2 values
%
%I/O: model = mpca(mwa,scale,nocomp);
%
%Example: model = mpca(mwa,'mncn',3); creates an MPCA model with
%  three components where the data has been mean centered.
%
%  Caution: This function works for arrays of order 4 and higher,
%  but the scaling options might not be what is desired. If you 
%  have any doubt, scale first then use without scaling.
%
%See also: MWFIT, GRAM, TLD, PARAFAC

%Copyright Eigenvector Research, Inc. 1998
%bmw
%Modified BMW April 1998

% Determine size of input array
mwasize = size(mwa);
order = length(mwasize);
% Number of rows in unfolded matrix
m = mwasize(order);
% Number of columns in unfolded matrix
n = prod(mwasize)/mwasize(order);
% Unfold the matrix
data = reshape(mwa,n,m)';
% If scaling not specified, do group scaling
if (nargin < 2 | isempty(scaling))
  scaling = 'grps';
end
% Scale data as specified
if (scaling == 2 | strcmp(scaling,'auto'))
  scaling = 'auto';
  [data,mns,stds] = auto(data);
elseif (scaling == 1 | strcmp(scaling,'mncn'))
  scaling = 'mncn';
  [data,mns] = mncn(data);
  stds = ones(1,n);
elseif (scaling == 3 | strcmp(scaling,'grps'))
  scaling = 'grps';
  % Calculate the stds along the second order
  stds = std(unfoldmw(mwa,2)');
  % Create vector of stds for scaling
  if order == 3
    stds = stds(ones(mwasize(1),1),:);
    stds = stds(:)';
  else
    stds = stds(ones(mwasize(1),1),:);
    stds = stds(:);
    stds = stds(:,ones(prod(mwasize(3:order-1)),1));
    stds = stds(:)';
    size(stds)
  end
  % Calculate the mean trajectory
  mns = mean(data);
  % Scale the data
  data = scale(data,mns,stds);
elseif  (scaling == 0 | strcmp(scaling,'none'));
  mns = zeros(1,n);
  stds = ones(1,n);
else
  error('Scaling not of known type')
end
if nargin < 3
  [scores,loads,ssq,res,q,tsq,tsqs] = pca(data,0);
  [ms,nocomp] = size(scores);
else
  [scores,loads,ssq,res,q,tsq,tsqs] = pca(data,0,[],nocomp);
end
model = struct('xname',inputname(1),'name','MPCA','date',date,'time',clock,...
  'size',mwasize,'nocomp',nocomp,'scale',scaling,'means',mns,'stds',stds,...
  'ssq',ssq,'scores',scores,'loads',loads,'res',res,'reslim',q,...
  'tsq',tsqs,'tsqlim',tsq);

