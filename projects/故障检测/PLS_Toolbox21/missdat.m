function [estdata] = missdat(data,pcs,flag,modl,tol,iter)
%MISSDAT PCA and PLS for matrices with missing data.
%  Warning - this function is obsolete and will be
%  removed in future versions. See MDPCA.')
%
%  Inputs are the input matrix (data), the number of principal
%  components or latent variables assumed to be significant
%  (pcs), the value of the flag used for missing data (flag)
%  [e.g. set flag = 9999 and put 9999 in the input matrix for
%  each missing value], a variable (modl) for method:
%    modl = 1 for PCA, and
%    modl = 2 for PLS.
%  Optional inputs (tol) sets the convergence tolerance
%  [default = 1e-5], and (iter) sets the number of iterations
%  [default = 50]. The output (estdata) is an estimate
%  of the data matrix with the missing values replaced.
%
%  This function works by setting missing values to zero then
%  calculating a PCA or PLS model. The missing values are
%  replaced with values most consistant with the model. A new
%  model is then calculated, and the process is repeated until
%  the estimates of the missing data converge.
%  The data matrix with missing values can be scaled prior to
%  using MISSDAT with MDMNCN or MDAUTO.
%
%I/O: estdata = missdat(data,pcs,flag,modl,tol,iter);
%
%See Also: MDAUTO, MDMNCN, MDPCA, MDRESCAL, MDSCALE, PLSRSGN,
%          PLSRSGCV, REPLACE, RPLCDEMO, RSGNDEMO

%Copyright Eigenvector Research, Inc. 1995-2000
%Modified NBG 10/96, 3/98
%nbg 11/00 added warning

disp('Warning - this function is obsolete and will be')
disp(' removed in future versions. See MDPCA')

if nargin < 6
  iter   = 50;
end
if nargin < 5
  tol    = 1e-5;
elseif isempty(tol)
  tol  = 1e-5;
end
[m,n]    = size(data);
mdlocs   = zeros(m,n);              % location of missing data
dtlocs   = ones(m,n);               % location of known data
locs     = find(data==flag);
mdlocs(locs) = ones(size(flag));
dtlocs(locs) = zeros(size(flag));
data(locs)   = zeros(size(flag));

totssq   = sum(sum(data.^2));
change   = 1;
count    = 0;

while change > tol
  count  = count + 1;
  disp(sprintf('Now working on iteration number %g',count))
  if modl == 1
    if n < m
      cov     = (data'*data)/(m-1);
      [u,s,v] = svd(cov);
    else
      cov     = (data*data')/(m-1);
      [u,s,v] = svd(cov);
      v = data'*v;
      for i = 1:m
        v(:,i) = v(:,i)/norm(v(:,i));
      end
    end
    loads     = v(:,1:pcs);
	scores    = data*loads;
	estdata   = data;
    model     = scores*loads';
    estdata(locs) = model(locs);     
  elseif modl == 2
    loads     = plsrsgn(data,pcs,0);
    estdata   = data;
    for ii = 1:m
      vars    = find(mdlocs(ii,:));
      if isempty(vars) == 0
        rm    = replace(loads,vars);
        estdata(ii,:) = data(ii,:)*rm;
      end
    end
  end 
  dif       = data - estdata;
  change    = sum(sum(dif.^2));
  s = sprintf('Sum of squared differences in missing data estimates = %g',change);
  disp(s)
  data      = estdata;
  if count == iter
    s = sprintf('Algorithm failed to converge after %g iterations',iter);
    disp(s)
    change  = 0;
  end
end
if modl ~=0, disp('  '), end
if modl == 1 
  disp('Now forming final PCA model')
  ssq = [[1:pcs]' zeros(pcs,2)];
  for i = 1:pcs
    resmat    = data - scores(:,1:i)*loads(:,1:i)';
    resmat    = resmat - resmat.*mdlocs;
    ssqres    = sum(sum(resmat.^2));
    ssq(i,3)  = (1 - ssqres/totssq)*100;
  end
  ssq(1,2)    = ssq(1,3);
  for i = 2:pcs
    ssq(i,2)  = ssq(i,3) - ssq(i-1,3);
  end
  disp('    Percent Variance Captured') 
  disp('           by PCA Model')
  disp('     Based on Known Data Only')
  disp('  ')
  disp('    PC#      %Var      %TotVar')
  disp(ssq)
elseif modl == 2
  disp('Now forming final PLS model')
end

