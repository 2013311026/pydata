function [scores,loads,estdata] = mdpca(data,pcs,flag,tol,out)
%MDPCA Principal Components for matrices with missing data.
%  Inputs are the matrix (data), and the number of principal
%  components assumed to be significant (pcs).
%
%  Optional input (flag) can be used to indicate missing values.
%  If not input (flag) is assumed to be NaN (i.e. each missing
%  value is a NaN). (flag) can also be a numberic value (e.g. 9999).
%  e.g. set  flag = 9999 and put 9999 for each missing value.
%  Optional variable (tol) sets the convergence tolerance
%  {default = 1e-5}.
%  Optional input (out) suppresses printing of convergence results
%  to the command window when set to 0 {default = 1}.
%
%  Outputs are the estimated principal components scores (scores),
%  loadings (loads), and an estimate of the data matrix with
%  missing values replaced (estdata). 
%
%  This function works by calculating a PCA model and then 
%  replacing the missing data with values that are most 
%  consistant with the model. A new PCA model is then 
%  calculated, and the process is repeated until the estimates 
%  of the missing data converge. This is one of many ways to
%  treat the missing data problem.
%
%I/O: [scores,loads,estdata] = mdpca(data,pcs,flag,tol,out);
%
%See also: PCA, MDDEMO

%Copyright Eigenvector Research, Inc. 1992-2000
%Modified 5/94 BMW
%nbg 11/00 allow for flag = NaN, and added out

if nargin<3
  flag   = NaN;
elseif isempty(flag)
  flag   = NaN;
end
if nargin<4
  tol    = 1e-5;
elseif isempty(tol)
  tol    = 1e-5;
end
if nargin<5
  out    = 1;
end

[m,n]    = size(data);
mdlocs   = zeros(m,n);
if isfinite(flag)
  locs   = find(data==flag);
else
  locs   = find(~isfinite(data));
end
mdlocs(locs) = ones(size(flag));
data(locs)   = zeros(size(flag));

totssq = sum(sum(data.^2));
change = 1;
count  = 0;
while change > tol
  if out~=0
    count = count + 1;
    disp(sprintf('Now working on iteration number %g',count));
  end
  if n < m
    cov = (data'*data)/(m-1);
    [u,s,v] = svd(cov);
  else
    cov = (data*data')/(m-1);
    [u,s,v] = svd(cov);
    v = data'*v;
    for i = 1:m
      v(:,i) = v(:,i)/norm(v(:,i));
    end
  end
  loads = v(:,1:pcs);
  scores = data*loads;
  estdata = data;
  for i = 1:m
    vars = find(mdlocs(i,:));
    if isempty(vars) == 0
      rm = replace(loads,vars);
      estdata(i,:) = data(i,:)*rm;
    end
  end
  dif = data - estdata;
  change = sum(sum(dif.^2));
  if out~=0
    disp(sprintf('Sum of squared differences in missing data estimates = %g',change));
  end
  data = estdata;
  if count == 50
    disp('Algorithm failed to converge after 50 iterations')
    change = 0;
  end
end
if out~=0
  disp('  ')
  disp('Now forming final PCA model')
  disp('   ')
end
ssq = [[1:pcs]' zeros(pcs,2)];
for i = 1:pcs
  resmat = data - scores(:,1:i)*loads(:,1:i)';
  resmat = resmat - resmat.*mdlocs;
  ssqres = sum(sum(resmat.^2));
  ssq(i,3) = (1 - ssqres/totssq)*100;
end
ssq(1,2) = ssq(1,3);
for i = 2:pcs
  ssq(i,2) = ssq(i,3) - ssq(i-1,3);
end
if out~=0
  disp('    Percent Variance Captured') 
  disp('           by PCA Model')
  disp('     Based on Known Data Only')
  disp('  ')
  disp('    PC#      %Var      %TotVar')
  disp(ssq)
end