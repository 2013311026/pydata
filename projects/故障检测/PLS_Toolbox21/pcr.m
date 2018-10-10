function [b,ssq,t,p,eigs] = pcr(x,y,pc,out)
%PCR Principal components regression for multivariate y.
%  Inputs are the matrix of predictor variables (x), vector
%  or matrix of predicted variable (y), maximum number
%  of principal components to consider (pc), and an optional
%  variable (out) to suppress intermediate output (out=0 suppresses
%  output {default = 1}. Outputs are the matrix of regression
%  coefficients (b) for each number of principal components,
%  where each block of ny rows corresponds to the PCR model
%  for that number of principal components, the sum of
%  squares information (ssq), the x-block scores (t), and
%  the x-block loadings (p).
%
%I/O: [b,ssq,t,p,eigs] = pcr(x,y,pc,out);
%
%See also: CROSSVAL, MODLGUI, PCA, PLS, RIDEG, SIMPLS

%Copyright Eigenvector Research, Inc. 1995-98
%Modified 4/96,12/97 NBG

if nargin < 4
  out = 1;
end
[mx,nx] = size(x);
[my,ny] = size(y);
if mx ~= my
  error('Number of samples in x- and y-blocks not equal.')
elseif pc > nx
  error('pc must be <= number of x-block variables.')
end
if nx < mx
  cov = (x'*x)/(mx-1);
  [u,s,v] = svd(cov);
  p = v(:,1:pc);
else
  cov = (x*x')/(mx-1);
  [u,s,v] = svd(cov);
  v = x'*v;
  for i = 1:pc
    v(:,i) = v(:,i)/norm(v(:,i));
  end
  p = v(:,1:pc);
end
eigs = diag(s);
t = x*p;
b = zeros(pc*ny,nx);
ssqty = zeros(pc,1);
ssqy = sum(sum(y.^2));
for i = 1:pc
  r = inv(t(:,1:i)'*t(:,1:i))*t(:,1:i)'*y;
  b(ny*(i-1)+1:ny*i,:) = (p(:,1:i)*r)';
  dif = y - t(:,1:i)*r;
  ssqty(i,1) =  ((ssqy - sum(sum(dif.^2)))/ssqy)*100;
end
temp = diag(s)*100/(sum(diag(s)));
temp = temp(1:pc);
ssqy = zeros(pc,1);
ssqy(1,1) = ssqty(1,1);
for i = 1:pc-1
  ssqy(i+1,1) = ssqty(i+1,1)-ssqty(i,1);
end
ssq = [(1:pc)' temp cumsum(temp) ssqy ssqty];
if out == 1
  disp('  ')
  disp('       Percent Variance Captured by PCR Model   ')
  disp('  ')
  disp('           -----X-Block-----    -----Y-Block-----')
  disp('   LV #    This PC    Total     This PC    Total ')
  disp('   ----    -------   -------    -------   -------')
  format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
  for i = 1:pc
    tab = sprintf(format,ssq(i,:)); disp(tab)
  end
  disp('  ')
end
