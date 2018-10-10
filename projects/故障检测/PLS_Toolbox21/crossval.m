function [press,cumpress,rmsecv,rmsec] = crossval(x,y,rm,cvm,lv,split,iter,mc,out,osc);
%CROSSVAL Cross-validation for PCA, PLS and PCR
%  This function does cross-validation for regression
%  and principal components analysis models by several
%  different methods including:
%   leave-one-out               ('loo')
%   venetian blind              ('vet') 
%   continuous blocks           ('con') 
%   repeated random test sets   ('rnd') 
%
%  The inputs are the scaled predictor variable matrix (x), 
%  predicted variable (y, not needed for PCA models), regression method
%  or PCA (rm) which can be:
%   PLS via NIPALS algorithm ('nip')   (Old, slow way of doing PLS)
%   PLS via SIMPLS algorithm ('sim')   (New, fast way of doing PLS)
%   PCR                      ('pcr')
%   MLR                      ('mlr')
%   PCA                      ('pca')   
%
%  cross-validation method (cvm, as described above), number of latent 
%  variables or principal components to calcluate (lv), number of
%  sections to split the data into (split, needed for 'vet', 'con'
%  and 'rnd' cross validations), number of iterations (iter, needed
%  for 'rnd'), an optional variable which suppresses mean centering
%  of the subsets when set to 0 (mc), an optional variable which
%  supresses the output when set to 0 (out), and an optional variable
%  which specifies the number of orthogonal signal correction components
%  to use (osc), which can be a three element vector which specifies
%  number of components, iterations and tolerance (osc = [nocomp,iter,tol]). 
%
%  The outputs are the predictive residual error
%  sum of squares (press) for each subset and the cumulative
%  PRESS (cumpress). Note that for multivariate y the press
%  output is grouped by output variable, i.e. all of the PRESS values
%  for the first variable are followed by all of the PRESS values
%  for the second variable, etc. Optional outputs are the root mean
%  square error of cross-validation (rmsecv) and root mean square
%  error of (rmsec). 
%
%I/O: [press,cumpress,rmsecv,rmsec] = crossval(x,y,rm,cvm,lv,split,iter,mc,out,osc);
% 
%  Some examples of how you might call CROSSVAL are:
%   [press,cumpress] = crossval(x,y,'mlr','loo');
%   [press,cumpress] = crossval(x,y,'nip','loo',10);
%   [press,cumpress] = crossval(x,y,'pcr','vet',10,3);
%   [press,cumpress] = crossval(x,y,'nip','con',10,5);
%   [press,cumpress] = crossval(x,y,'sim','rnd',10,3,20);
%
%  To suppress mean centering in the first two cases:
%   [press,cumpress] = crossval(x,y,'mlr','loo',[],[],[],0);
%   [press,cumpress] = crossval(x,y,'nip','loo',10,[],[],0);
%
%  To add orthogonal signal correction with 2 components:
%   [press,cumpress] = crossval(x,y,'sim','vet',10,3,[],[],[],2);
%   [press,cumpress] = crossval(x,y,'pcr','con',10,3,[],[],[],2);
% 
%  For use with PCA, you might call CROSSVAL like:
%   [press,cumpress] = crossval(x,[],'pca','loo',10);
%   [press,cumpress] = crossval(x,[],'pca','vet',10,3);
%   [press,cumpress] = crossval(x,[],'pca','con',10,5);
%
%See also: CROSSVUS, OSCCALC

%Copyright Eigenvector Research, Inc. 1997-8
%Modified by BMW 7/17/97, 4/6/97
%NBG 7/98, 9/98 
%BMW 12/98 -added OSC
%BMW 1/99 -improved OSC

if strcmp(rm,'mlr')
  lv = 1;
end
if isempty(x)
  error('xblock matrix is empty')
elseif isempty(rm)
  error('regression type not specified')
elseif isempty(cvm)
  error('cross-validation method not specified')
elseif lv > min(size(x))
  error('number of LVs must be <= min(size(x))')
end
[mx,nx] = size(x);
if strcmp(rm,'pca')
  y = zeros(mx,1);
  reg = 0;
else
  reg = 1;
end
[my,ny] = size(y);
cumpress = zeros(ny,lv);
if (nargin < 8 | isempty(mc))
  mc = 1;
end
if (nargin < 9 | isempty(out))
  out = 1;
end
if (nargin < 10 | isempty(osc))
  osc = 0; oiter = []; otol = [];
else
  if length(osc) > 1
    oiter = osc(2);
  else
    oiter = [];
  end
  if length(osc) > 2
    otol = osc(3)
  else
    otol = [];
  end
  osc = osc(1);
end
if strcmp(cvm,'loo')
  % Do leave one out
  press = zeros(mx*ny,lv);
  for i = 1:mx
    if mc ~= 0
      [calx,mnsx] = mncn([x(1:i-1,:);[x(i+1:mx,:)]]);
      testx = scale(x(i,:),mnsx);
      [caly,mnsy] = mncn([y(1:i-1,:);[y(i+1:mx,:)]]);
      testy = scale(y(i,:),mnsy);
    else
      calx = [x(1:i-1,:);[x(i+1:mx,:)]];
      testx = x(i,:);
      caly = [y(1:i-1,:);[y(i+1:mx,:)]];
      testy = y(i,:);  
    end
    if osc ~= 0
      [calx,nw,np] = osccalc(calx,caly,osc,oiter,otol);
      testx = testx - testx*nw*inv(np'*nw)*np';
    end
    if strcmp(rm,'sim')
      bbr = simpls(calx,caly,lv);
    elseif strcmp(rm,'pcr')
      bbr = pcr(calx,caly,lv,0);
    elseif strcmp(rm,'nip')
      bbr = pls(calx,caly,lv,0);
    elseif strcmp(rm,'mlr')
      bbr = (calx\caly)';
    elseif strcmp(rm,'pca')
      [u,s,v] = svd(calx,0);
      rpca = eye(nx)-v(:,1)*v(:,1)';
      repmat = zeros(nx);
    else
      error('Regression method not of known type')
    end
    for j = 1:lv
      if reg == 1
        ypred = testx*bbr((j-1)*ny+1:j*ny,:)';
        press((i-1)*ny+1:i*ny,j) = ((ypred-testy).^2)';
      else 
        for kkk = 1:nx
          repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
          repmat(kkk,kkk) = -1;
        end
        press(i,j) = sum(sum((testx*repmat).^2));
        if j ~= lv
          rpca = rpca - v(:,j+1)*v(:,j+1)';
        end
      end
    end
  end
  for i = 1:ny
    cumpress(i,:) = sum(press(i:ny:mx*ny,:),1);
  end
elseif strcmp(cvm,'vet')
  % Do venetian blinds
  press = zeros(split*ny,lv);
  for i = 1:split
    ind = zeros(mx,1);
    count = 0;
    for j = 1:mx
      test = round((j+i-1)/split) - ((j+i-1)/split);
      if test == 0
        ind(j,1) = 1;
        count = count + 1;
      end
    end
    [a,b] = sort(ind);
    newx = x(b,:);
    newy = y(b,:);
    if mc ~= 0
      [calx,mnsx] = mncn(newx(1:mx-count,:));
      testx = scale(newx(mx-count+1:mx,:),mnsx);
      [caly,mnsy] = mncn(newy(1:mx-count,:));
      testy = scale(newy(mx-count+1:mx,:),mnsy);
    else
      calx = newx(1:mx-count,:);
      testx = newx(mx-count+1:mx,:);
      caly = newy(1:mx-count,:);
      testy = newy(mx-count+1:mx,:);
    end
    if osc ~= 0
      [calx,nw,np] = osccalc(calx,caly,osc,oiter,otol);
      testx = testx - testx*nw*inv(np'*nw)*np';
    end
    if strcmp(rm,'sim')
      bbr = simpls(calx,caly,lv);
    elseif strcmp(rm,'pcr')
      bbr = pcr(calx,caly,lv,0);
    elseif strcmp(rm,'nip')
      bbr = pls(calx,caly,lv,0);
    elseif strcmp(rm,'mlr')
      bbr = (calx\caly)';
    elseif strcmp(rm,'pca')
      [u,s,v] = svd(calx,0);
      rpca = eye(nx)-v(:,1)*v(:,1)';
      repmat = zeros(nx);
    else
      error('Regression method not of known type')
    end
    for j = 1:lv
      if reg == 1
        ypred = testx*bbr((j-1)*ny+1:j*ny,:)';
        press((i-1)*ny+1:i*ny,j) = sum((ypred-testy).^2)';
      else 
        for kkk = 1:nx
          repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
          repmat(kkk,kkk) = -1;
        end
        press(i,j) = sum(sum((testx*repmat).^2));
        if j ~= lv
          rpca = rpca - v(:,j+1)*v(:,j+1)';
        end
      end
    end
  end
  for i = 1:ny
    cumpress(i,:) = sum(press(i:ny:split*ny,:),1);
  end
elseif strcmp(cvm,'con')
  % Use contiguous subsets
  press = zeros(split*ny,lv);
  ind = ones(split,2);
  for i = 1:split
    ind(i,2) = round(i*mx/split);
  end 
  for i = 1:split-1
    ind(i+1,1) = ind(i,2) +1;
  end
  for i = 1:split
    if mc ~= 0
      [calx,mnsx] = mncn([x(1:ind(i,1)-1,:); x(ind(i,2)+1:mx,:)]);
      testx = scale(x(ind(i,1):ind(i,2),:),mnsx);
      [caly,mnsy] = mncn([y(1:ind(i,1)-1,:); y(ind(i,2)+1:mx,:)]);
      testy = scale(y(ind(i,1):ind(i,2),:),mnsy);
    else
      calx = [x(1:ind(i,1)-1,:); x(ind(i,2)+1:mx,:)];
      testx = x(ind(i,1):ind(i,2),:);
      caly = [y(1:ind(i,1)-1,:); y(ind(i,2)+1:mx,:)];
      testy = y(ind(i,1):ind(i,2),:);
    end
    if osc ~= 0
      [calx,nw,np] = osccalc(calx,caly,osc,oiter,otol);
      testx = testx - testx*nw*inv(np'*nw)*np';
    end
    if strcmp(rm,'sim')
      bbr = simpls(calx,caly,lv);
    elseif strcmp(rm,'pcr')
      bbr = pcr(calx,caly,lv,0);
    elseif strcmp(rm,'nip')
      bbr = pls(calx,caly,lv,0);
    elseif strcmp(rm,'mlr')
      bbr = (calx\caly)';
    elseif strcmp(rm,'pca')
      [u,s,v] = svd(calx,0);
      rpca = eye(nx)-v(:,1)*v(:,1)';
      repmat = zeros(nx);
    else
      error('Regression method not of known type')
    end
    for j = 1:lv
      if reg == 1
        ypred = testx*bbr((j-1)*ny+1:j*ny,:)';
        press((i-1)*ny+1:i*ny,j) = sum((ypred-testy).^2)';
      else  
        for kkk = 1:nx
          repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
          repmat(kkk,kkk) = -1;
        end
        press(i,j) = sum(sum((testx*repmat).^2));
        if j ~= lv
          rpca = rpca - v(:,j+1)*v(:,j+1)';
        end
      end
    end
  end
  for i = 1:ny
    cumpress(i,:) = sum(press(i:ny:split*ny,:),1);
  end
elseif strcmp(cvm,'rnd')
  % Use random repeated subsets
  press = zeros(split*iter*ny,lv);
  kk = 0;
  ind = ones(split,2);
  for i = 1:split
    ind(i,2) = round(i*mx/split);
  end 
  for i = 1:split-1
    ind(i+1,1) = ind(i,2) +1;
  end
  for k = 1:iter
    [z,inds] = sort(randn(mx,1));
    xx = x(inds,:);
    yy = y(inds,:);
    for i = 1:split
      kk = kk + 1;
      if mc ~= 0
        [calx,mnsx] = mncn([xx(1:ind(i,1)-1,:); xx(ind(i,2)+1:mx,:)]);
        testx = scale(xx(ind(i,1):ind(i,2),:),mnsx);
        [caly,mnsy] = mncn([yy(1:ind(i,1)-1,:); yy(ind(i,2)+1:mx,:)]);
        testy = scale(yy(ind(i,1):ind(i,2),:),mnsy);
      else
        calx = [xx(1:ind(i,1)-1,:); xx(ind(i,2)+1:mx,:)];
        testx = xx(ind(i,1):ind(i,2),:);
        caly = [yy(1:ind(i,1)-1,:); yy(ind(i,2)+1:mx,:)];
        testy = yy(ind(i,1):ind(i,2),:);
      end
      if osc ~= 0
        [calx,nw,np] = osccalc(calx,caly,osc,oiter,otol);
        testx = testx - testx*nw*inv(np'*nw)*np';
      end
      if strcmp(rm,'sim')
        bbr = simpls(calx,caly,lv);
      elseif strcmp(rm,'pcr')
        bbr = pcr(calx,caly,lv,0);
      elseif strcmp(rm,'nip')
        bbr = pls(calx,caly,lv,0);
      elseif strcmp(rm,'mlr')
        bbr = (calx\caly)';
      elseif strcmp(rm,'pca')
        [u,s,v] = svd(calx,0);
        rpca = eye(nx)-v(:,1)*v(:,1)';
        repmat = zeros(nx);
      else
        error('Regression method not of known type')
      end
      for j = 1:lv
        if reg == 1
          ypred = testx*bbr((j-1)*ny+1:j*ny,:)';
          li = (i-1)*ny+1 + (k-1)*ny*split;
          ui = i*ny + (k-1)*ny*split;
          press(li:ui,j) = sum((ypred-testy).^2)';
        else  
          for kkk = 1:nx
            repmat(:,kkk) = -(1/rpca(kkk,kkk))*rpca(:,kkk);
            repmat(kkk,kkk) = -1;
          end
          press(i + (k-1)*split,j) = sum(sum((testx*repmat).^2));
          if j ~= lv
            rpca = rpca - v(:,j+1)*v(:,j+1)';
          end
        end
      end
    end
  end  
  for i = 1:ny
    cumpress(i,:) = sum(press(i:ny:split*ny*iter,:),1);
  end
else
  error('Cross-validation method not of known type')
end
if ny > 1
  [mp,np] = size(press);
  ind = zeros(mp,1);
  blk = mp/ny;
  for i = 1:ny
    ind((i-1)*blk+1:blk*i,1) = (i:ny:mp)'; 
  end
  press = press(ind,:);
end
rmsecv  = sqrt(cumpress/mx);

if ~(nargout<4 & out==0)
  if osc ~= 0
    x = osccalc(x,y,osc,oiter,otol);
  end
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
      rmsec(:,j1) = sum(sum((x*repmat).^2));
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
      if strcmp(rm,'nip')
        s1 = 'CV for PLS via NIPALS, ';
      elseif strcmp(rm,'sim')
        s1 = 'CV for PLS via SIMPLS, ';
      elseif strcmp(rm,'pcr')
        s1 = 'CV for PCR, ';
      end
      if strcmp(cvm,'loo')
        s2 = 'leave-one-out, ';
      elseif strcmp(cvm,'vet')
        s2 = 'venetian blinds, ';
      elseif strcmp(cvm,'con')
        s2 = 'contiguous blocks, ';
      elseif strcmp(cvm,'rnd')
        s2 = 'random splits, ';
      end
      if ~strcmp(cvm,'loo')
        s3 = sprintf('%g way split, ',split);
      else
        s3 = [];
      end
      if strcmp(cvm,'rnd')
        s4 = sprintf('%g iterations, ',iter);
      else
        s4 = [];
      end
      if mc == 0;
        s5 = 'MC supressed, ';
      else
        s5 = [];
      end
      if osc == 1
        s6 = '1 OSC component, ';
      elseif osc > 1
        s6 = sprintf('%g OSC components, ',osc);
      else
        s6 = [];
      end
      s = [s1 s2 s3 s4 s5 s6];
      [ms,ns] = size(s);
      s(1,ns-1:ns) = '. ';
      title(s)
    end
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
