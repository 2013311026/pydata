function [mcx,mx] = mdmncn(x,flag)
%MDMNCN Mean centers matrix with missing data to mean zero.
%  Mean centers matrix (x) with missing values indicated by (flag),
%  returning a matrix with mean zero columns (mcx) and the vector
%  of means (mx) used in the scaling.(flag) can be numeric or NaN
%  (flag not supplied or flag = [] implies NaN).
%
%I/O: [mcx,mx] = mdmncn(x,flag);
%
%See also:  AUTO, MDAUTO, MDRESCAL, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research 1997-2000
%By Barry M. Wise
%nbg 11/00 added NaN

if nargin<2
  flag = NaN;
elseif isempty(flag)
  flag = NaN;
end

[m,n] = size(x);
mx    = zeros(1,n);
mcx   = ones(m,n)*flag;
for ii=1:n
  if isfinite(flag)
    z   = find(x(:,ii)~=flag);
  else
    z   = find(isfinite(x(:,ii)));
  end
  mx(ii)    = mean(x(z,ii));
  mcx(z,ii) = x(z,ii)-mx(ii);
end

%[m,n] = size(x);
%mx = zeros(1,n);
%mcx = ones(m,n)*flag;
%for i = 1:n
%  z = find(x(:,i)~=flag);
%  mx(i) = mean(x(z,i));
%  mcx(z,i) = x(z,i)-mx(i);
%end