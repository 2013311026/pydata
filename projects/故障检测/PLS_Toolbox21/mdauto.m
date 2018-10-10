function [ax,mx,stdx] = mdauto(x,flag)
%MDAUTO Autoscales matrix with missing data to mean zero unit variance.
%  Autoscales matrix (x) with missing values indicated by (flag),
%  returning a matrix with columns with zero mean and unit variance
%  columns (ax), the vectors of means (mx), and standard deviations
%  (stdx) used in the scaling. (flag) can be numeric or NaN
%  (flag not supplied or flag = [] implies NaN).
%
%I/O: [ax,mx,stdx] = mdauto(x,flag);
%
%See also:  AUTO, MDMNCN, MDRESCAL, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-2000
%By Barry M. Wise
%nbg 11/00 added NaN

if nargin<2
  flag = NaN;
elseif isempty(flag)
  flag = NaN;
end

[m,n] = size(x);
mx    = zeros(1,n);
stdx  = zeros(1,n);
ax    = ones(m,n)*flag;
for ii=1:n
  if isfinite(flag)
    z   = find(x(:,ii)~=flag);
  else
    z   = find(isfinite(x(:,ii)));
  end
  mx(ii)   = mean(x(z,ii));
  stdx(ii) = std(x(z,ii));
  ax(z,ii) = (x(z,ii)-mx(ii))/stdx(ii);
end
