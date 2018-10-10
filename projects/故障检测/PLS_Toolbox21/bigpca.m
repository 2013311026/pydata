function [scores,loads,ssq,res,q,tsq,tsqs] = bigpca(data,maxpc,plots,ss,ls)
%BIGPCA Principal components analysis for BIG matrices
%  This function uses svd to perform pca on a large data matrix.
%  It is assumed that samples are rows and variables are columns. 
%  Inputs are the input matrix (data), and the maximum
%  number of PCs to calculate (maxpc), an optional variable
%  (plots) that controls the graphs produced (see below), and
%  two optional ploting scale vectors for the scores (ss) 
%  and for the loadings (ls) for plotting scores and loads against.
%  The outputs are the scores (scores), loadings (loads), 
%  variance info (ssq), residuals (res), calculated q limit (q), 
%  t^2 limit (tsq) and t^2 values (tsqs).
%
%I/O: [scores,loads,ssq,res,q,tsq,tsqs] = bigpca(data,maxpc,plots,ss,ls);
%
%  Set plots = 0 to suppress all plots, plots = 1 for plots with
%  no confidence limits and plots = 2 for plots with limits.
%  If you would like to scale the data before processing use the 
%  functions AUTO or SCALE. For smaller matrices, the PCA
%  function is faster.
%
%See also: PCA, PLTSCRS, PLTLOADS, SIMCA

%  Copyright Eigenvector Research, Inc. 1991-98
%  Modified BMW 11/93, 1/95 NBG 4/96
%  Modified BMW 11/98, 11/2000

if nargin < 3
  plots = 1;
end
if plots > 2
  error('Plot option must be 0, 1 or 2')
elseif plots < 0
  error('Plot option must be 0, 1 or 2')
end
[m,n] = size(data);
if n < m
  cov = zeros(n,n);
  for i = 1:n
    for j = 1:i
	  cov(i,j) = (data(:,i)'*data(:,j))/(m-1);
	  cov(j,i) = cov(i,j);
	end
  end
  [u,s,v] = svd(cov);
  temp2 = (1:maxpc)';
  escl = 1:maxpc;
  v = v(:,1:maxpc);
else
  cov = zeros(m,m);
  for i = 1:m
    for j = 1:i
	  cov(i,j) = (data(i,:)*data(j,:)')/(m-1);
	  cov(j,i) = cov(i,j);
	end
  end
  [u,s,v] = svd(cov);
  v = (v(:,1:maxpc)'*data)';
  for i = 1:maxpc
    v(:,i) = v(:,i)/norm(v(:,i));
  end
  temp2 = (1:maxpc)';
  escl = 1:maxpc;
end
mns = mean(data);
ssqmns = mns*mns';
ssqtot = sum(diag(cov));
clear cov
if ssqtot/ssqmns < 1e10
  disp('  ')
  disp('Warning: Data does not appear to be mean centered.')
  disp('Variance captured table should be read as sum of')
  disp('squares captured.') 
end
temp = diag(s)*100/(sum(diag(s)));
temp = temp(1:maxpc);
ssq = [temp2 diag(s(1:maxpc,1:maxpc)) temp cumsum(temp)];
%  This section calculates the standard errors of the
%  eigenvalues and plots them
if plots == 2
  eigmax = ssq(:,2)/(1-(1.96*sqrt(2/m)));
  eigmin = ssq(:,2)/(1+(1.96*sqrt(2/m)));
  clg
  plot(escl,ssq(:,2),escl,eigmax,'--b',escl,eigmin,'--b',escl,ssq(:,2),'og')
  title('Eigenvalue vs. PC Number showing 95% Confidence Limits')
  xlabel('PC Number')
  ylabel('Eigenvalue')
elseif plots == 1
  clf
  plot(escl,ssq(:,2),escl,ssq(:,2),'og')
  title('Eigenvalue vs. PC Number')
  xlabel('PC Number')
  ylabel('Eigenvalue')
end 
%  Print out the amount of variance captured 
disp('   ')
disp('        Percent Variance Captured by PCA Model')
disp('  ')
disp('Principal     Eigenvalue     % Variance     % Variance')
disp('Component         of          Captured       Captured')
disp(' Number         Cov(X)        This  PC        Total')
disp('---------     ----------     ----------     ----------')
format = '   %3.0f         %3.2e        %6.2f         %6.2f';
for i = 1:maxpc
  tab = sprintf(format,ssq(i,:)); disp(tab)
end
input('How many principal components do you want to keep?  ');
nmaxpc = ans;
if nmaxpc > maxpc
  disp('No. of PCs must be <= original number of PCs calculated')
  str = sprintf('Setting number of PCs = %g',maxpc);
  disp(str)
  nmaxpc = maxpc;
else
  maxpc = nmaxpc;
end
%  Form the PCA Model Based on the Number of PCs Chosen
loads = v(:,1:maxpc);
scores = data*loads;

%  Calculate the standard error on the PC loadings if needed
if plots == 2
  loaderr = zeros(n,maxpc);
  if n > m 
    nn = m; 
  else
    nn = n; 
  end
  ssqb = diag(s);
  for i = 1:maxpc
    dif = (ssqb-ones(nn,1)*ssqb(i)).^2;
    dif = sort(dif);
    sig = sum((ones(nn-1,1)*ssqb(i))./dif(2:nn,1));
    loaderr(:,i) = ((ssqb(i)/m)*loads(:,i).^2)*sig;
  end
  loadmax = loads+loaderr;
  loadmin = loads-loaderr;
end
%  Calculate the residuals matrix and Q values
res = zeros(m,1);
for i = 1:m
  data(i,:) = (data(i,:) - scores(i,:)*loads');
  res(i) = sum(data(i,:).^2);
end
clear data
%  Create the scale vectors to plot against
if plots >= 1.0
  if nargin < 4
    ss = 1:m;
    scllim = [1 m];
  else
    scllim = [min(ss) max(ss)];
  end
  if nargin < 5
    ls = 1:n;
  end
  temp = [1 1];
  for i = 1:maxpc
    pclim = sqrt(s(i,i))*temp*1.96;
    plot(ss,scores(:,i),scllim,pclim,'--b',scllim,-pclim,'--b')
	%hold on, plot(ss,scores(:,i),'+g'), hold off
    xlabel('Sample Number')
    str = sprintf('Score on PC# %g',i);
    ylabel(str)
    title('Sample Scores with 95% Limits')
    pause
    if plots == 2  
	  plot(ls,loads(:,i),ls,loadmax(:,i),'--b',...
	  ls,loadmin(:,i),'--b',[min(ls) max(ls)],[0 0]) %ls,loads(:,i),'og',
    elseif plots == 1
      plot(ls,loads(:,i),[min(ls) max(ls)],[0 0]) %,ls,loads(:,i),'og'
    end
  xlabel('Variable Number')
  str = sprintf('Loadings for PC# %g',i);
  ylabel(str)
  if plots == 2
    str = sprintf('Variable # vs. Loadings for PC# %g Showing Standard Errors',i);
    title(str)
  else
    str = sprintf('Variable Number vs. Loadings for PC# %g',i);
    title(str)
  end
  pause
end
end
%  Calculate Q limit using unused eigenvalues
temp = diag(s);
if n < m
  emod = temp(maxpc+1:n,:);
else
  emod = temp(maxpc+1:m,:);
end
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
disp('The 95% Q limit is')
disp(q)
if plots >= 1
  lim = [q q];
  plot(ss,res,scllim,lim,'--b') %,ss,res,'+g'
  str = sprintf('Process Residual Q with 95 Percent Limit Based on %g PC Model',maxpc);
  title(str)
  xlabel('Sample Number')
  ylabel('Residual')
  pause
end
%  Calculate T^2 limit using ftest routine
if maxpc > 1
  if m > 300
    tsq = (maxpc*(m-1)/(m-maxpc))*ftest(.05,maxpc,300);
  else
    tsq = (maxpc*(m-1)/(m-maxpc))*ftest(.05,maxpc,m-maxpc);
  end
  disp('  ')
  disp('The 95% T^2 limit is')
  disp(tsq)
%  Calculate the value of T^2 by normalizing the scores to
%  unit variance and summing them up
  temp2 = scores*inv(diag(ssq(1:maxpc,2).^.5));
  tsqs = sum((temp2.^2)');
  if plots >= 1.0
    tlim = [tsq tsq];
    plot(ss,tsqs,scllim,tlim,'--b') %,ss,tsqvals,'+g'
    str = sprintf('Value of T^2 with 95 Percent Limit Based on %g PC Model',maxpc);
    title(str)
    xlabel('Sample Number')
    ylabel('Value of T^2')
  end
else
  disp('T^2 not calculated when number of latent variables = 1')
  tsq = 1.96^2;
  tsqs = scores.^2/ssq(1,2);
end
