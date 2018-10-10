function [press,cumpress,rmsecv,rmsec] = crossvus(x,y,rm,cvi,lv,out,mc);
%CROSSVUS User defined subset cross-validation for PCA, PLS and PCR
%  CROSSVUS performs cross-validation for regression and
%  principal components analysis models using pre-defined
%  data subsets for calibration and test sets.
%
%  Inputs include the scaled predictor variable matrix (x), and
%  predicted variable (y), [not needed for PCA models]. Input (rm)
%  defines the regression method or PCA (rm) which can be:
%   rm = 'nip': PLS via NIPALS algorithm (slower iterative algorithm PLS)
%   rm = 'sim': PLS via SIMPLS algorithm (fast algorithm for PLS)
%   rm = 'pcr': PCR
%   rm = 'mlr': MLR
%   rm = 'pca': PCA
%
%  Input (cvi) is a vector with integer elements defining data subsets:
%    -2 the sample is always in the test set,
%    -1 the sample is always in the calibration set,
%     0 the sample is never used, and
%     1,2,3,... defines each subset.
%  Note that length(cvi) must = size(x,1);
%
%  Input (lv) is the number of latent variables or principal components
%  to calcluate, optional variable (out) is used to suppress output when
%  set to 0 [default = 1], and an optional variable which suppresses
%  mean centering of the subsets when set to 0 (mc).
%  Outputs are (press) the predictive residual error sum of squares PRESS
%  for each subset, the cumulative PRESS (cumpress), root mean square
%  error of cross validation (rmsecv), and the root mean square error of
%  calibration (rmsec). Note that for multivariate y the press
%  output is grouped by output variable, i.e. all of the PRESS values
%  for the first variable are followed by all of the PRESS values
%  for the second variable, etc.
%
%I/O: [press,cumpress,rmsecv,rmsec] = crossvus(x,y,rm,cvi,lv,out,mc);
% 
%See also: CROSSVAL

%Copyright Eigenvector Research, Inc. 1998-2000
%nbg  1/00

if strcmp(rm,'mlr')
  lv   = 1;
end
if isempty(x)
  error('ERROR - xblock matrix is empty')
elseif isempty(rm)
  error('ERROR - regression type not specified')
elseif isempty(cvi)
  error('ERROR - cross-validation subsets not specified')
elseif lv>min(size(x))
  error('ERROR - number of LVs must be <= min(size(x))')
elseif length(cvi)~=size(x,1)
  error('ERROR - length(cvi) must equal size(x,1)')
end
[mx,nx] = size(x);
if strcmp(rm,'pca')
  y     = zeros(mx,1);
  reg   = 0;
else
  reg   = 1;
end
if nargin<6
  out   = 1;
end
if nargin<7
  mc    = 1;
end
cumpress = zeros(size(y,2),lv);

isamp   = [1:mx]';            % eliminate cvi==0 samples
isamp   = delsamps(isamp,find(cvi==0));
x       = x(isamp,:);
y       = y(isamp,:);
cvi     = cvi(isamp,:);
[mx,nx] = size(x);            % identify subsets
ny      = size(y,2);
isamp   = [1:mx]';
itst0   = find(cvi==-2);      % test samples
ical0   = find(cvi==-1);      % cal samples
isamp   = isamp(find(cvi>0)); % subsets
if length(isamp)>0
  [cvi,cvj] = sort(cvi(isamp));
  isamp   = isamp(cvj);
  cvk     = find(diff(cvi));
  lcvk    = length(cvk)+1;
  samps   = cell(lcvk,1);
  for ii=1:lcvk-1
    samps{ii,1} = isamp(find(cvi==cvi(cvk(ii))));
  end
  samps{lcvk,1} = isamp(find(cvi==cvi(cvk(lcvk-1)+1)));
  press   = zeros(lcvk*ny,lv);
  %if nargout>4
  %  stdb    = press;
  %  bcv     = zeros(lcvk*ny,lv,
  %end
end
for ii=1:lcvk
  ical  = [ical0;delsamps([1:mx]',samps{ii})];
  itst  = [itst0;samps{ii}];
  if mc~=0
    [calx,mnsx] = mncn(x(ical,:));
    tstx  = scale(x(itst,:),mnsx);
    [caly,mnsy] = mncn(y(ical,:));
    tsty  = scale(y(itst,:),mnsy);
  else
    calx  = x(ical,:);
    tstx  = x(itst,:);
    caly  = y(ical,:);
    tsty  = y(itst,:);
  end
  switch rm
  case 'sim'
    bbr = simpls(calx,caly,lv,[],0);
  case 'pcr'
    bbr = pcr(calx,caly,lv,0);
  case 'nip'
    bbr = pls(calx,caly,lv,0);
  case 'mlr'
    bbr = (calx\caly)';
  case 'pca'
    [u,s,v] = svd(calx,0);
    rpca = eye(nx)-v(:,1)*v(:,1)';
    repmat = zeros(nx);
  otherwise
    error('ERROR - Regression method not of known type')
  end
  for j1= 1:lv
    if reg == 1
      ypred = tstx*bbr((j1-1)*ny+1:j1*ny,:)';
      press((ii-1)*ny+1:ii*ny,j1) = sum((ypred-tsty).^2)';
    else 
      for kkk = 1:nx
        repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
        repmat(kkk,kkk) = -1;
      end
      press(ii,j1) = sum(sum((tstx*repmat).^2));
      if j1~=lv
        rpca = rpca - v(:,j1+1)*v(:,j1+1)';
      end
    end
  end
end
clear calx tstx caly tsty ical itst ypred repmat
for jj=1:ny
  cumpress(jj,:) = sum(press(jj:ny:lcvk*ny,:),1);
end

if ny > 1
  [mp,np] = size(press);
  ind   = zeros(mp,1);
  blk  = mp/ny;
  for ii=1:ny
    ind((ii-1)*blk+1:blk*ii,1) = (ii:ny:mp)'; 
  end
  press = press(ind,:);
end

rmsecv  = sqrt(cumpress/mx);

switch rm
case 'sim'
  [bbr,ssq] = simpls(x,y,lv,[],0);
case 'pcr'
  [bbr,ssq] = pcr(x,y,lv,0);
case 'nip'
  [bbr,ssq] = pls(x,y,lv,0);
case 'mlr'
  bbr   = (x\y)';
case 'pca'
  %need to put in cov(x)...
  [u,s,v] = svd(x'*x/(mx-1),0);
  rpca  = eye(nx)-v(:,1)*v(:,1)';
  repmat = zeros(nx);
  rmsec = zeros(size(press));
  for j1=1:lv
    for kkk = 1:nx
      repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
      repmat(kkk,kkk) = -1;
    end
    rmsec(ii,j1) = sum(sum((x*repmat).^2));
    if j1~=lv
      rpca = rpca - v(:,j1+1)*v(:,j1+1)';
    end
  end
  rmsec = sqrt(sum(rmsec)/mx);
  if out~=0
    ssq = zeros(lv,4);
    ssq(:,1) = [1:lv]';
    ssq(:,2) = diag(s(1:lv,1:lv));
    ssq(:,3) = ssq(:,2)/sum(diag(s))*100;
    ssq(:,4) = cumsum(ssq(:,3));    
    h = plotyy([1:lv],ssq(1:lv,2),[1:lv],rmsecv);
    set(get(h(1),'children'),'color',[0 0 1],'marker','p')
    set(get(h(1),'ylabel'),'string','Eigenvalue of Cov(x) (p)', ...
      'color',[0 0 0])
    set(h(1),'ycolor',[0 0 0])
    set(get(h(2),'children'),'color',[1 0 0],'marker','s')
    set(get(h(2),'ylabel'),'string','RMSECV (s)')
    set(h(2),'ycolor',[0 0 0])
    axes(h(2))
   % h1 = line('marker','o','color','b','xdata',[1:lv],'ydata',rmsec);
    xlabel('Latent Variable')
    dispssqp(ssq,lv)
  end
end
if reg==1
  rmsec = zeros(size(cumpress));
  for j1= 1:lv
    ypred = x*bbr((j1-1)*ny+1:j1*ny,:)';
    rmsec(:,j1) = sum((ypred-y).^2)';
  end
  rmsec = sqrt(rmsec/mx);
  if (out~=0)&(~strcmp(rm,'mlr'))
    plot([1:lv],rmsecv,'-or',[1:lv],rmsec,'-sb')
   % legend('RMSECV','RMSEC')
    xlabel('Latent Variable')
    ylabel('RMSECV (o), RMSEC (s)')
    dispssqr(ssq,lv)
  end
end

function [] = dispssqr(ssq,lv)
disp('  ')
disp('       Percent Variance Captured by PLS Model   ')
disp('  ')
disp('           -----X-Block-----    -----Y-Block-----')
disp('   LV #    This LV    Total     This LV    Total ')
disp('   ----    -------   -------    -------   -------')
format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
for ii=1:lv
  tab = sprintf(format,ssq(ii,:)); disp(tab)
end
disp('  ')

function [] = dispssqp(ssq,lv)
disp('   ')
disp('        Percent Variance Captured by PCA Model')
disp('  ')
disp('Principal     Eigenvalue     % Variance     % Variance')
disp('Component         of          Captured       Captured')
disp(' Number         Cov(X)        This  PC        Total')
disp('---------     ----------     ----------     ----------')
format = '   %3.0f         %3.2e        %6.2f         %6.2f';
for ii=1:lv
  tab = sprintf(format,ssq(ii,:)); disp(tab)
end
