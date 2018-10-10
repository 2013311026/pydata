function model = imgpca(mwa,scaling,nocomp)
%IMGPCA Principal Components Analysis of Multivariate Images
%  IMGPCA uses principal components analysis to make
%  psuedocolor maps of multivariate images. The input is the
%  multivariate image (mwa). Optional inputs are (scaling) the
%  scaling to be used, and the number of PCs to calculate (nocomp).
%    scaling = 'auto' uses autoscaling {default},
%    scaling = 'mncn' uses mean centering, and
%    scaling = 'none' uses no scaling.
%
%  It is assumed that the image (mwa) is a 3 dimensional (m x n x p)
%  array where each image is m x n pixels and there are p images.
%  IMGPCA presents each scores, residual, and T^2 matrix as a
%  psuedocolor image. If 3 are more PCs are selected (nocomp>=3),
%  a composite of the first three  PCs is shown as an rgb image,
%  with red for the first PC, green for the second, and blue for the
%  the third.
%
%  The output (model) is a structure with the following fields:
%
%     xname: input data name
%      name: type of model, always 'IPCA'
%      date: date of model creation
%      time: time of model creation
%      size: dimensions of input data
%    nocomp: number of PCs in model
%     scale: type of scaling used
%     means: mean vector for PCA model
%      stds: standard deviation vector for PCA model
%       ssq: variance captured table data
%    scores: PCA scores stored as m x n x nocomp array (uint8)
%     range: Original range of PCA scores before mapping to uint8
%     loads: PCA loadings
%       res: PCA residuals stored as m x n array (uint8)
%    reslim: Q limit
%       tsq: PCA T^2 values stared as m x n array (unit8)
%    tsqlim: T^2 limit
%
%  Note that the scores, residuals and T^2 matrices are stored
%  as unsigned 8 bit integers (uint8) scaled so their range is 
%  0 to 255. These can be viewed with the IMAGE function, but 
%  be sure the current colormap has 256 colors. For example, to
%  view the scores on the second PC using the jet colormap:
%
%   image(model.scores(:,:,2)), colormap(jet(256)), colorbar
%
%I/0: model = imgpca(mwa,scaling,nocomp);
%
%See also: IMREAD, MWFIT, IMGSELCT, IMGSIMCA, ISIMCAPR

%Copyright Eigenvector Research, Inc. 1998-2000
%BMW
%nbg 11/00 changed help

ms = size(mwa);
nr = ms(1)*ms(2);
mwa = reshape(mwa,nr,ms(3));
% If scaling not specified, set it to auto scaling
if (nargin < 2 | isempty(scaling))
  scaling = 'auto';
end
% Initial matrix for range of scores, res and T^2
if strcmp(class(mwa),'double')
  % Scale data as specified
  if (scaling == 2 | strcmp(scaling,'auto'))
    scaling = 'auto';
    [mwa,mns,stds] = auto(mwa);
  elseif (scaling == 1 | strcmp(scaling,'mncn'))
    scaling = 'mncn';
    [mwa,mns] = mncn(mwa);
    stds = ones(1,ms(3));
  elseif  (scaling == 0 | strcmp(scaling,'none'));
    scaling = 'none';
    mns = zeros(1,ms(3));
    stds = ones(1,ms(3));
  else
    error('Scaling not of known type')
  end
  if nargin < 3
    [scores,loads,ssq,res,q,tsq,tsqs] = pca(mwa,0);
    [ns,nocomp] = size(scores);
  else
    [scores,loads,ssq,res,q,tsq,tsqs] = pca(mwa,0,[],nocomp);
  end
  % Change sign on scores and loads so loads are mostly positive
  scores = scores*diag(sign(sum(loads)));
  loads = loads*diag(sign(sum(loads)));
  % Store original range of scores, res and T^2
  scr = zeros(2,nocomp+2);
  scr(1,1:nocomp) = min(scores);
  scr(2,1:nocomp) = max(scores);
  scr(1,nocomp+1) = min(res);
  scr(2,nocomp+1) = max(res);
  scr(1,nocomp+2) = min(tsqs);
  scr(2,nocomp+2) = max(tsqs);
  % Change score, res and T^2 range to be 0-255, make uint8
  for i = 1:nocomp
    scores(:,i) = round(255*(scores(:,i)-min(scores(:,i)))/...
      max(scores(:,i)-min(scores(:,i))));
  end
  scores = uint8(scores);
  res = uint8(255*res/max(res));
  tsqs = uint8(255*tsqs/max(tsqs));
elseif strcmp(class(mwa),'uint8')
  % Calculate the scatter matrix
  scmat = zeros(ms(3),ms(3));
  for i = 1:ms(3)
    for j = 1:i  
      scmat(i,j) = double(mwa(:,i))'*double(mwa(:,j));
      if i ~= j
        scmat(j,i) = scmat(i,j);
      end
    end
  end
  % Scale data as specified
  if (scaling == 2 | strcmp(scaling,'auto'))
    scaling = 'auto';
    mns = mean(mwa);
    stds = sqrt((diag(scmat)' + nr*mns.^2 - 2*sum(mwa).*mns)/...
      (nr-1)); 
    scmat = (inv(diag(stds))*(scmat - mns'*mns*nr)*inv(diag(stds)))/...
      (nr-1);
  elseif (scaling == 1 | strcmp(scaling,'mncn'))
    scaling = 'mncn';
    mns = mean(mwa);
    scmat = (scmat - mns'*mns*nr)/(nr-1);
    stds = ones(1,ms(3));
  elseif  (scaling == 0 | strcmp(scaling,'none'));
    scaling = 'none';
    scmat = scmat/(nr-1);
    mns = zeros(1,ms(3));
    stds = ones(1,ms(3));
  else
    error('Scaling not of known type')
  end
  % Calculate the loadings
  if nargin < 3
    [u,s,loads] = svd(scmat);
    nocomp = ms(3);
  else
    [u,s,loads] = svd(scmat);
  end
  % Change the sign on the loads to be mostly positive
  loads = loads*diag(sign(sum(loads)));
  % Display the variance captured table.
  if strcmp(scaling,'none')
    disp('  ')
    disp('Warning: Data was not mean centered.')
    disp(' Variance captured table should be read as sum of')
    disp(' squares captured.') 
  end
  temp = diag(s(1:nocomp,1:nocomp))*100/(sum(diag(s)));
  ssq  = [[1:nocomp]' diag(s(1:nocomp,1:nocomp)) temp cumsum(temp)];
  disp('   ')
  disp('        Percent Variance Captured by PCA Model')
  disp('  ')
  disp('Principal     Eigenvalue     % Variance     % Variance')
  disp('Component         of          Captured       Captured')
  disp(' Number         Cov(X)        This  PC        Total')
  disp('---------     ----------     ----------     ----------')
  format = '   %3.0f         %3.2e        %6.2f         %6.2f';
  mprint = min([20 nocomp]);
  for i = 1:mprint
    tab = sprintf(format,ssq(i,:)); disp(tab)
  end
  % Select the number of PCs
  flag = 0;
  while flag == 0;
    ss = sprintf('How many PCs do you want to keep? Max = %g ',nocomp);
    lv = input(ss);
    if lv > nocomp
      disp(sprintf('Number of PCs must be >= %g',nocomp))
    elseif lv < 1
      disp('Number of PCs must be > 0')
    elseif isempty(lv)
      disp('Number of PCs must be > 0')
    else
      flag = 1;
    end
  end
  % Truncate the loads
  nocomp = lv;
  loads = loads(:,1:nocomp);
  % Calculate the scores
  scores = uint8(zeros(nr,nocomp));
  scr = zeros(2,nocomp+2);
  for j = 1:nocomp
    ts = zeros(nr,1);
    if strcmp(scaling,'none')
      for i = 1:nr
        ts(i,:) = double(mwa(i,:))*loads(:,j);
      end
    elseif strcmp(scaling,'mncn')
      for i = 1:nr
        ts(i,:) = (double(mwa(i,:))-mns)*loads(:,j);
      end 
    elseif strcmp(scaling,'auto')
      for i = 1:nr
        ts(i,:) = ((double(mwa(i,:))-mns)./stds)*loads(:,j);
      end     
    end
    scr(1,j) = min(ts);
    scr(2,j) = max(ts);
    scores(:,j) = round(255*(ts-min(ts))/max(ts-min(ts)));
  end
  % Calculate the residuals and T^2
  imppt = eye(ms(3))-loads*loads';
  res = zeros(nr,1);
  tsqs = zeros(nr,1);
  if strcmp(scaling,'none')
    for i = 1:nr
      smwa = double(mwa(i,:));
      res(i) = sum((smwa*imppt).^2);
      tsqs(i) = sum(((smwa*loads)./sqrt(ssq(1:nocomp,2)')).^2);
    end
  elseif strcmp(scaling,'mncn')
    for i = 1:nr
      smwa = double(mwa(i,:))-mns;
      res(i) = sum((smwa*imppt).^2);
      tsqs(i) = sum(((smwa*loads)./sqrt(ssq(1:nocomp,2)')).^2);
    end
  elseif strcmp(scaling,'auto')
    for i = 1:nr
      smwa = (double(mwa(i,:))-mns)./stds;
      res(i) = sum((smwa*imppt).^2);
      tsqs(i) = sum(((smwa*loads)./sqrt(ssq(1:nocomp,2)')).^2);
    end
  end
  scr(1,nocomp+1) = min(res);
  scr(2,nocomp+1) = max(res);
  res = uint8(255*res/max(res));
  scr(1,nocomp+2) = min(tsqs);
  scr(2,nocomp+2) = max(tsqs);
  tsqs = uint8(255*tsqs/max(tsqs));
  % Calculate the Q limit
  if nocomp < ms(3);
    temp = diag(s);
    emod = temp(nocomp+1:end);
    th1 = sum(emod);
    th2 = sum(emod.^2);
    th3 = sum(emod.^3);
    h0 = 1 - ((2*th1*th3)/(3*th2^2));
    if h0 <= 0.0
      h0 = .0001;
      disp('  ')
      disp('Warning:  Distribution of unused eigenvalues indicates that')
      disp('          you should probably retain more PCs in the model.')
    end
    q = th1*(((1.65*sqrt(2*th2*h0^2)/th1) + 1 + th2*h0*(h0-1)/th1^2)^(1/h0));
    disp('  ')
    str = sprintf('The 95 Percent Q limit is %g',q);
    disp(str)
  else
    q = 0;
  end
  %  Calculate T^2 limit using ftest routine
  if nr > 300
    tsq = (nocomp*(nr-1)/(nr-nocomp))*ftest(.05,nocomp,300);
  else
    tsq = (nocomp*(nr-1)/(nr-nocomp))*ftest(.05,nocomp,nr-nocomp);
  end
  disp('  '), str = sprintf('The 95 Percent T^2 limit is %g',tsq); disp(str)
end

% Fold the scores, residuals and T^2s back up
scores = reshape(scores,ms(1),ms(2),nocomp);
res = reshape(res,ms(1),ms(2));
tsqs = reshape(tsqs,ms(1),ms(2));
zs = figure('position',[145 166 512 384],'name','Image Pixel Scores');
zl = figure('position',[170 130 512 384],'name','Image Variable Loadings');
for i = 1:nocomp
  figure(zl)
  plot(loads(:,i),'-ob'), hline(0)
  title(sprintf('Loadings for PC #%g',i));
  xlabel('Variable Number')
  ylabel('Loading')
  figure(zs);
  colormap(hot(256));
  z1 = image(scores(:,:,i)); z2 = colorbar;
  z1p = get(z1,'parent');
  set(z1p,'xtick',[],'ytick',[])
  title(sprintf('Scores on PC# %g',i))
  if ~strcmp(scaling,'none')
    pclim = sqrt(ssq(i,2))*1.96;
    up = 255*(pclim-scr(1,i))/(scr(2,i)-scr(1,i));
    lw = 255*(-pclim-scr(1,i))/(scr(2,i)-scr(1,i));
    xlabel(sprintf('Scaled 95 Percent limits are %g and %g',up,lw));
  end
  pause
end
figure(zs)
set(zs,'name','Image Pixel Residuals')
colormap(hot(256));
z1 = image(res); z2 = colorbar;
z1p = get(z1,'parent');
set(z1p,'xtick',[],'ytick',[])
title('Residual')
lim = 255*q/scr(2,nocomp+1);
xlabel(sprintf('Scaled 95 Percent Q limit is %g',lim));
pause
set(zs,'name','Image Pixel T^2')
z1 = image(tsqs); z2 = colorbar;
z1p = get(z1,'parent');
set(z1p,'xtick',[],'ytick',[])
title('T^2 Values')
lim = 255*tsq/scr(2,nocomp+2);
xlabel(sprintf('Scaled 95 Percent T^2 limit is %g',lim));
pause
if nocomp >= 3
  set(zs,'name','Image Pixel Pseudocolor')
  z1 = image(scores(:,:,1:3));
  z1p = get(z1,'parent');
  set(z1p,'xtick',[],'ytick',[])
  title('False Color Image of First 3 PCs')
end

model = struct('xname',inputname(1),'name','IPCA','date',date,'time',clock,...
  'size',ms,'nocomp',nocomp,'scale',scaling,'means',mns,'stds',stds,...
  'ssq',ssq,'scores',scores,'range',scr,'loads',loads,'res',res,'reslim',q,...
  'tsq',tsqs,'tsqlim',tsq);
