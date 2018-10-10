function model = mwfit(mwa,model,plots);
%MWFIT Fits existing TLD, PARAFAC, MPCA or IMGPCA model to new data
%  This function can be used to fit a model developed with
%  the TLD, PARAFAC, MPCA or IMGPCA functions to a new multi-way
%  array. The assumption in TLD, PARAFAC and MPCA is that the last 
%  order is fit, i.e. the sample dimension is the last order. With
%  IMGPCA models the third order is fixed and the first two are
%  fit. Inputs are the new data (mwa) and the TLD, PARAFAC, 
%  MPCA or IMGPCA model (model) in structured array form. Optional
%  input (plots) suppresses plotting when set to 0. The output 
%  is a structured array (fitmodel) with the following elements:
%
%      xname: name of the original workspace input variable
%       name: type of model, always 'MWFIT'
%    modname: name of the original workspace input model
%    modtype: type of input model (TLD, PARAFAC, MPCA or IPCA)
%       date: date stamp of fitting the model
%       time: time stamp of fitting the model
%       size: size of the input arrary
%     nocomp: number of components estimated
%      loads: 1 by order cell array of the loadings in each dimension
%        res: 1 by order cell array residuals summed over each dimension
%
%  Plots are produced showing the loadings for each factor in the final
%  dimension. Reference lines are drawn at the mean and +/- three standard
%  deviations of the loadings based on the original data. Approximate 99%
%  and 5x99% limits are shown on residuals based on the original distribution.
%  Note: these are rather crude ways of setting limits, but there is little
%  agreement currently as to how exactly this should be done.
%
%I/O: fitmodel = mwfit(mwa,model,plots);
%
%See also: MPCA, PARAFAC, TLD

% Copyright Eigenvector Research, Inc. 1998-2000
% bmw
% nbg 2/00 (added plots option), 8/00 (added plots option to mpca)
% nbg 11/00 (fixed spelling error in help)

if nargin<3
  plots = 1;
end
mwasize = size(mwa);
% If the model isn't MPCA or IPCA, do the following
if ~(strcmp(model.name,'MPCA') | strcmp(model.name,'IPCA'))
  order = length(model.size);
  % Check to see if model size fits data size
  if mwasize(1:order-1) ~= model.size(1:order-1)
    error('Model size does not match new data dimensions')
  end
  % Unfold the input array along the last order
  mwauf = unfoldmw(mwa,order)';
  x0 = model.loads;
  % Multiply the loadings together so they can be fit to the data
  mwauflo = zeros(prod(mwasize)/mwasize(order),model.nocomp);
  for j = 1:model.nocomp
    mwvect = x0{1}(:,j);
    for k = 2:order-1
      mwvect = mwvect*x0{k}(:,j)';
      mwvect = mwvect(:);
    end
    mwauflo(:,j) = mwvect;
  end
  % Regress the actual data on the loadings to get new loads in last order
  ordiest = mwauflo\mwauf;
  x0{order} = ordiest';
  % Calculate the residuals in the last order
  res = (mwa-outerm(x0)).^2;
  for i = 1:order-1
    res = sum(res,i);
  end
  res = squeeze(res);

  if plots~=0  %added 2/00
    % Plot the estimated loadings in the last order
    o = int2str(order);
    for i = 1:model.nocomp
      subplot(model.nocomp+1,1,i)
      plot(ordiest(i,:)','-*b')
      if i == 1
        title('Loadings (Fit to Model) with +/- Three Standard Deviations from Original Data')
      end
      if i == 1
        xlabel('Sample Number')
      end
      hline(mean(model.loads{order}(:,i)'))
      hline(mean(model.loads{order}(:,i)')+3*std(model.loads{order}(:,i)))
      hline(mean(model.loads{order}(:,i)')-3*std(model.loads{order}(:,i)))
      ylabel(sprintf('Loadings Factor %g',i))
    end
    subplot(model.nocomp+1,1,model.nocomp+1)
    semilogy(res,'-*b')
    title(sprintf('Residuals in Last Order (%g) with Approximate 99%% and 5x99%% Limits',order))
    xlabel('Sample Number')
    ylabel('Residual SSQ')  
    hline(mean(model.res{order}))
    sr = sort(model.res{order});
    hline(sr(floor(model.size(order)*0.99)))
    hline(sr(floor(model.size(order)*0.99))*5)
  end
  model = struct('xname',inputname(1),'name','MWFIT','modname',inputname(2),...
  'modtype',model.name,'date',date,'time',clock,'size',mwasize,'nocomp',model.nocomp);
  model.loads = x0;
  dif = (mwa-outerm(x0)).^2;
  res = cell(1,order);
  for i = 1:order
    x = dif;
    for j = 1:order
      if i ~= j
        x = sum(x,j);
      end
    end
    x = squeeze(x);
    res{i} = x(:);
    si = int2str(i);
  end
  model.res = res;
% If the model is MPCA, do the following
elseif strcmp(model.name,'MPCA')
  mwasize = size(mwa);
  order = length(mwasize);
  if mwasize(1:order-1) ~= model.size(1:order-1)
    error('Model size does not match new data dimensions')
  end
  m = mwasize(order);
  n = prod(mwasize)/mwasize(order);
  data = reshape(mwa,n,m)';
  if (model.scale == 'auto' | model.scale == 'grps')
    data = scale(data,model.means,model.stds);
  elseif model.scale == 'mncn'
    data = scale(data,model.means);
  end
  [scores,resids,tsqs] = pcapro(data,model.loads,model.ssq,model.reslim,...
  model.tsqlim,plots);
  [ms,nocomp] = size(scores);
  model = struct('xname',inputname(1),'name','MWFIT','date',date,'time',clock,...
  'size',mwasize,'nocomp',nocomp,'scores',scores,'res',resids,'tsqs',tsqs);
% If the model is IPCA, do the following
elseif strcmp(model.name,'IPCA')
  ms = size(mwa);
  if ms(3) ~= model.size(3)
    error('Models and image size incompatible--wrong image depth')
  end
  % Reshape the data matrix
  nr = ms(1)*ms(2);
  mwa = reshape(mwa,nr,ms(3));
  if strcmp(class(mwa),'double')
    % Scale data as specified
    if strcmp(model.scale,'auto')
      mwa = scale(mwa,model.means,model.stds);
    elseif strcmp(model.scale,'mncn')
      mwa = scale(mwa,model.means);
    elseif strcmp(model.scale,'none')
      % Don't need to do anything
    else
      error('Scaling not of known type')
    end
    % Calculate the new scores, residuals and T^2
    [scores,res,tsqs] = pcapro(mwa,model.loads,model.ssq,...
      model.reslim,model.tsqlim,0);
    % Range scale score, res and T^2 
    for i = 1:model.nocomp
      scores(:,i) = round(255*(scores(:,i)-model.range(1,i))/...
        (model.range(2,i)-model.range(1,i)));
    end
    res = 255*res/model.range(2,model.nocomp+1);
    tsqs = 255*tsqs/model.range(2,model.nocomp+2);
    % Check for out of range scores, reset
    if (any(scores>255) | any(scores<0))
      scores(find(scores>255)) = 255;
      scores(find(scores<0)) = 0;
    end
    % Check for out of range res and T^2
    if any(res>255)
      res(find(res>255)) = 255;
    end
    if any(tsqs>255)
      tsqs(find(tsqs>255)) = 255;
    end
    % Convert to uint8
    scores = uint8(scores);
    res = uint8(res);
    tsqs = uint8(tsqs);
  elseif strcmp(class(mwa),'uint8') 
    % Calculate the new scores
    scores = uint8(zeros(nr,model.nocomp));
    for j = 1:model.nocomp
      ts = zeros(nr,1);
      if strcmp(model.scale,'none')
        for i = 1:nr
          ts(i,:) = double(mwa(i,:))*model.loads(:,j);
        end
      elseif strcmp(model.scale,'mncn')
        for i = 1:nr
          ts(i,:) = (double(mwa(i,:))-model.means)*model.loads(:,j);
        end 
      elseif strcmp(model.scale,'auto')
        for i = 1:nr
          ts(i,:) = ((double(mwa(i,:))-model.means)./model.stds)*model.loads(:,j);
        end     
      end
      % Range scale the scores
      scores(:,j) = round(255*(ts-model.range(1,j))/(model.range(2,j)-model.range(1,j)));
    end
    % Check for out of range scores, reset
    if (any(scores>255) | any(scores<0))
      scores(find(scores>255)) = 255;
      scores(find(scores<0)) = 0;
    end
    % Calculate the residuals and T^2
    imppt = eye(ms(3))-model.loads*model.loads';
     res = zeros(nr,1);
    tsqs = zeros(nr,1);
    if strcmp(model.scale,'none')
      for i = 1:nr
        smwa = double(mwa(i,:));
        res(i) = sum((smwa*imppt).^2);
        tsqs(i) = sum(((smwa*model.loads)./sqrt(model.ssq(1:model.nocomp,2)')).^2);
      end
    elseif strcmp(model.scale,'mncn')
      for i = 1:nr
        smwa = double(mwa(i,:))-model.means;
        res(i) = sum((smwa*imppt).^2);
        tsqs(i) = sum(((smwa*model.loads)./sqrt(model.ssq(1:model.nocomp,2)')).^2);
      end
    elseif strcmp(model.scale,'auto')
      for i = 1:nr
        smwa = (double(mwa(i,:))-model.means)./model.stds;
        res(i) = sum((smwa*imppt).^2);
        tsqs(i) = sum(((smwa*model.loads)./sqrt(model.ssq(1:model.nocomp,2)')).^2);
      end
    end
    % Range scale the res and T^2 
    res = 255*res/model.range(2,model.nocomp+1);
    tsqs = 255*tsqs/model.range(2,model.nocomp+2);
    % Check for out of range res and T^2
    if any(res>255)
      res(find(res>255)) = 255;
    end
    if any(tsqs>255)
      tsqs(find(tsqs>255)) = 255;
    end
    % Convert to uint8
    scores = uint8(scores);
    res = uint8(res);
    tsqs = uint8(tsqs);
  end
  % Plot it up!
  % Fold the scores, residuals and T^2s back up
  scores = reshape(scores,ms(1),ms(2),model.nocomp);
  res = reshape(res,ms(1),ms(2));
  tsqs = reshape(tsqs,ms(1),ms(2));
  if plots~=0 %added 2/00
    zs = figure('position',[145 166 512 384],'name','New Image Pixel Scores');
    zl = figure('position',[170 130 512 384],'name','Image Variable Loadings');
  end
  cm = hot(256);
  cm(1,:) = [0 0 1];
  cm(256,:) = [0 1 0];
  if plots~=0 %added 2/00
    for i = 1:model.nocomp
      figure(zl)
      plot(model.loads(:,i),'-ob'), hline(0)
      title(sprintf('Loadings for PC #%g',i));
      xlabel('Variable Number')
      ylabel('Loading')
      figure(zs);
      colormap(cm);
      z1 = image(scores(:,:,i)); z2 = colorbar;
      z1p = get(z1,'parent');
      set(z1p,'xtick',[],'ytick',[])
      title(sprintf('New Scores on PC# %g',i))
      if ~strcmp(model.scale,'none')
        pclim = sqrt(model.ssq(i,2))*1.96;
        up = 255*(pclim-model.range(1,i))/(model.range(2,i)-model.range(1,i));
        lw = 255*(-pclim-model.range(1,i))/(model.range(2,i)-model.range(1,i));
        xlabel(sprintf('Scaled 95 Percent limits are %g and %g',up,lw));
      end
      pause
    end
    figure(zs)
    set(zs,'name','New Image Pixel Residuals')
    cm = hot(256);
    cm(256,:) = [0 1 0];
    colormap(cm);
    z1 = image(res); z2 = colorbar;
    z1p = get(z1,'parent');
    set(z1p,'xtick',[],'ytick',[])
    title('Residual')
    lim = 255*model.reslim/model.range(2,model.nocomp+1);
    xlabel(sprintf('Scaled 95 Percent Q limit is %g',lim));
    pause
    set(zs,'name','Image Pixel T^2')
    z1 = image(tsqs); z2 = colorbar;
    z1p = get(z1,'parent');
    set(z1p,'xtick',[],'ytick',[])
    title('T^2 Values')
    lim = 255*model.tsqlim/model.range(2,model.nocomp+2);
    xlabel(sprintf('Scaled 95 Percent T^2 limit is %g',lim));
    pause
    if model.nocomp >= 3
      set(zs,'name','New Image Pixel Pseudocolor')
      z1 = image(scores(:,:,1:3));
      z1p = get(z1,'parent');
      set(z1p,'xtick',[],'ytick',[])
      title('False Color Image of First 3 PCs')
    end
  end
  model = struct('xname',inputname(1),'name','MWFIT','modname',model.name,...
  'date',date,'time',clock,...
  'size',ms,'nocomp',model.nocomp,'scale',model.scale,'means',model.means,...
  'stds',model.stds,'ssq',model.ssq,'scores',scores,'range',model.range,...
  'loads',model.loads,'res',res,'reslim',model.reslim,...
  'tsq',tsqs,'tsqlim',model.tsqlim);
    
% If the model isn't any of these, error!
else
  error('Model not of known type')
end
