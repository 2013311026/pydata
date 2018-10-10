function model = parafac(mwa,nocomp,scl,tol,x0,ls,plots,nn);
%PARAFAC Parallel factor analysis for n-way arrays
%  PARAFAC will decompose an array of order n (where n >= 3)
%  into the summation over the outer product of n vectors.
%  The inputs are the multi-way array to be decomposed
%  (mwa), the number of components to estimate (nocomp), and
%  the optional inputs of a cell array of vectors for plotting
%  loads against (scl), the converge tolerance (tol, a 1 by 3
%  vector consisting of the relative change in fit, absolute change
%  in fit and maximum iterations, default is tol = [1e-6 1e-6 10000]), 
%  the initial estimate of the factors (x0), a flag (ls) which turns
%  off the line search options when set to zero, and a flag (plots)
%  which turns off the plotting of the loads and residuals when set
%  to zero. The output is a structured array (model) containing the 
%  PARAFAC model elements:
%
%     xname: name of the original workspace input variable
%      name: type of model, always 'PARAFAC'
%      date: model creation date stamp
%      time: model creation time stamp
%      size: size of the original input array
%     ncomp: number of components estimated
%       tol: tolerance vector used during model creation
%     final: final tolerances at termination
%       ssq: total and residual sum of squares
%     loads: 1 by order cell array of the loadings in each dimension
%       res: 1 by order cell array residuals summed over each dimension
%       scl: 1 by order cell array with scales for plotting loads 
%
%  This routine uses alternating least squares (ALS) in combination with
%  a line search every fifth iteration. For 3-way data, the intial estimate
%  of the loadings is obtained from the tri-linear decomposition (TLD).
%
%I/O: model = parafac(mwa,nocomp,scl,tol,x0,ls,plots);
%
%See also:  GRAM, MPCA, MWFIT, OUTER, OUTERM, TLD, UNFOLDM, XPLDST

%Copyright Eigenvector Research, Inc. 1998
%bmw March 4, 1998

mwasize = size(mwa);
order = ndims(mwa);
if (nargin < 3 | ~strcmp(class(scl),'cell'))
  scl = cell(1,order);
end
if (nargin < 4 | tol == 0)
  tol = [1e-6 1e-6 10000];
end
if nargin < 6
  ls = 1;
end
if nargin < 7
  plots = 1;
end
if nargin < 8
  nn = zeros(1,order);
end
% Initialize the routine if not already given
if (nargin < 5 | ~strcmp(class(x0),'struct') )
  x0 = cell(1,order);
  if order == 3
    % Initialize with TLD estimates
    m = tld(mwa,nocomp,0,0);
	x0 = m.loads;
  else
    for j = 1:order
      x0{1,j} = rand(mwasize(j),nocomp);
    end
  end
else
  if strcmp(class(x0),'struct')
    x0 = x0.loads;
  elseif ~strcmp(class(x0),'cell')
    error('Initial estimate x0 not a cell or structure')
  end
end
% Calculate total sum of squares in data
mwasq = mwa.^2;
tssq = sum(mwasq(:));

% Initialize the unfolded matrices
mwauf = cell(1,order);
mwauflo = cell(1,order);
mwaufsize = zeros(1,order);
for i = 1:order
  mwauf{i} = unfoldmw(mwa,i)';
  mwaufsize(i) = prod(mwasize)/mwasize(i);
  mwauflo{i} = zeros(prod(mwasize)/mwasize(i),nocomp);
end

% Initialize other variables needed in the ALS
oldx0 = x0;
searchdir = x0;
iter = 0;
flag = 0;
oldests = zeros(prod(mwasize)*nocomp,1);
% Start the ALS
while flag == 0;
  iter = iter+1;
  % Loop over each of the order to estimate
  for i = 1:order
    % Multiply the loads of all the orders together
    % except for the order to be estimated
    for j = 1:nocomp
      if i == 1
        mwvect = x0{2}(:,j);
        for k = 3:order  
          mwvect = mwvect*x0{k}(:,j)';
          mwvect = mwvect(:);
	    end
	  else
        mwvect = x0{1}(:,j);
        for k = 2:order
          if k ~= i
            mwvect = mwvect*x0{k}(:,j)';
            mwvect = mwvect(:);
          end
	    end
      end
      mwauflo{i}(:,j) = mwvect;
    end	
    % Regress the actual data on the estimate to get new loads in order i
    if nn(i) == 0 %| iter < 3)
	  ordiest = mwauflo{i}\mwauf{i};
    else
      ordiest = zeros(nocomp,mwasize(i));
      for k = 1:mwasize(i)
        [mwauflo{i} mwauf{i}(:,k)], x0{i}(k,:)'
        ordiest(:,k) = fastnnls(mwauflo{i},mwauf{i}(:,k),1e-8,x0{i}(k,:)');
      end
      if any(sum(ordiest,2)==0);
        disp([mwauflo{i} mwauf{i}])
      end
    end
	% Normalize the estimates (except the last order) and store them in the cell
	if i ~= order
      x0{i} = ordiest'*diag(1./sqrt(sum(ordiest.^2,2)));
      ii = i+1;
    else
	  x0{i} = ordiest';
      ii = 1;
	end
  end
  % Calculate the estimate of the input array based on current loads
  mwaest = zeros(prod(mwasize),nocomp);
  for j = 1:nocomp
    mwavect = x0{1}(:,j);
    for ii = 2:order
      mwavect = mwavect*x0{ii}(:,j)';
      mwavect = mwavect(:);
    end
    mwaest(:,j) = mwavect;
  end
  mwaest = sum(mwaest,2);
  mwasq = reshape(mwaest,mwasize);
  % Check to see if the fit has changed significantly
  mwasq = (mwa-mwasq).^2;
  ssq = sum(mwasq(:));
  %disp(sprintf('On iteration %g ALS fit = %g',iter,ssq));
  if iter > 1
    abschange = abs(oldssq-ssq);
    relchange = abschange/ssq;
    if relchange < tol(1)
      flag = 1;
      disp('Iterations terminated based on relative change in fit error')
    elseif abschange < tol(2)
      flag = 1;
      disp('Iterations terminated based on absolute change in fit error')
    elseif iter > tol(3)
      flag = 1;
      disp('Iterations terminated based on maximum iterations')
    end
  end
  if iter/100 == round(iter/100)
    disp([iter relchange abschange])
  end
  oldssq = ssq;
  
  % Every fifth iteration do a line search if ls == 1
  if (iter/5 == round(iter/5) & ls == 1) 
    % Determine the search direction as the difference between the last two estimates
    for i = 1:order
      searchdir{i} = x0{i} - oldx0{i};
    end
    % Initialize other variables required for line search
    testmod = x0; 
    sflag = 0; 
    i = 0; 
    sd = zeros(10,1); 
    sd(1) = ssq;
    xl = zeros(10,1);
    while sflag == 0
      for k = 1:order
        testmod{k} = testmod{k} + (2^i)*searchdir{k};
      end
      % Calculate the fit error on the new test model
      mwasq = (mwa - outerm(testmod)).^2;
      % Save the difference and the distance along the search direction
      sd(i+2) = sum(mwasq(:));
      xl(i+2) = xl(i+1) + 2^i;
      i = i+1;
      % Check to see if a minimum has been exceeded once two new points are calculated
      if i > 1 
        if sd(i+1) > sd(i)
          sflag = 1;
          % Estimate the minimum along the search direction
          xstar = sum((xl([i i+1 i-1]).^2 - xl([i+1 i-1 i]).^2).*sd(i-1:i+1));
          xstar = xstar/(2*sum((xl([i i+1 i-1]) - xl([i+1 i-1 i])).*sd(i-1:i+1)));
          % Save the old model and update the new one
          oldx0 = x0;
          for k = 1:order
            x0{k} = x0{k} + xstar*searchdir{k};
          end
        end
      end
    end 
    % Calculate the estimate of the input array based on current loads
    mwaest = zeros(prod(mwasize),nocomp);
    for j = 1:nocomp
      mwavect = x0{1}(:,j);
      for ii = 2:order
        mwavect = mwavect*x0{ii}(:,j)';
        mwavect = mwavect(:);
      end
      mwaest(:,j) = mwavect;
    end
    mwaest = sum(mwaest,2);
    mwasq = reshape(mwaest,mwasize);
    mwasq = (mwa - mwasq).^2;
    oldssq = sum(mwasq(:));
    %disp(sprintf('SSQ at xstar is %g',oldssq))
  else
    % Save the last estimates of the loads
    oldx0 = x0;
  end
end

% Plot the loadings
if plots ~= 0
  h1 = figure('position',[170 130 512 384],'name','PARAFAC Loadings');
  for i = 1:order
    subplot(order,1,i)
    if ~isempty(scl{i})
      if mwasize(i) <= 50
        plot(scl{i},x0{i},'-+')
      else
         plot(scl{i},x0{i},'-')
      end
    else
      if mwasize(i) <= 50
        plot(x0{i},'-+')
      else
        plot(x0{i},'-')
      end
    end
    ylabel(sprintf('Dimension %g',i))
    if i == 1
      title('Loadings for Each Dimension')
    end
  end
end

% Calculate and plot the residuals  
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
  if plots ~= 0
    if i == 1  
      figure('position',[145 166 512 384],'name','PARAFAC Residuals')
    end
    subplot(order,1,i)
    if ~isempty(scl{i})
      if mwasize(i) <= 50
        plot(scl{i},res{i},'-+')
      else
        plot(scl{i},res{i},'-')
      end
    else
      if mwasize(i) <= 50
        plot(res{i},'-+')
      else
        plot(res{i},'-')
      end
    end
    ylabel(sprintf('Dimension %g',i))
    if i == 1
      title('Residuals for Each Dimension')
    end
  end
end

% Bring the loads back to the front
if plots ~= 0
  figure(h1)
end

% Save the model as a structured array    
model = struct('xname',inputname(1),'name','PARAFAC','date',date,'time',clock,...
  'size',mwasize,'nocomp',nocomp,'tol',tol,'final',[relchange abschange iter]);
model.ssq = [tssq ssq];
model.loads = x0;
model.res = res;
model.scl = scl;
