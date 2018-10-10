function sx = mdscale(x,flag,mx,stdx)
%MDSCALE Scales matrix with missing data as specified.
%  Scales a matrix (x) with missing data indicated by (flag)
%  using means (mx) and standard deviations (stds) specified.
%  (flag) can be numeric or NaN (flag = [] implies NaN).
%
%I/O:  sx = mdscale(x,flag,mx,stdx);
%
%  If only three input arguments are supplied then the function
%  will not do variance scaling, but only vector subtraction.
%
%I/O:  sx = mdscale(x,flag,mx);
%
%See also: AUTO, MDAUTO, MDMNCN, MDRESCAL, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-2000
%By Barry M. Wise
%nbg 11/00 added NaN

if isempty(flag)
  flag = NaN;
end

[m,n] = size(x);
sx    = ones(m,n)*flag;
if nargin==4
  for ii=1:n
    if isfinite(flag)
      z = find(x(:,ii)~=flag);
    else
      z = find(isfinite(x(:,ii)));
    end
    sx(z,ii) = (x(z,ii)-mx(ii))./stdx(ii);
  end
else
  for ii=1:n
    if isfinite(flag)
      z = find(x(:,ii)~=flag);
    else
      z = find(isfinite(x(:,ii)));
    end
    sx(z,ii) = x(z,ii)-mx(ii);
  end
end
