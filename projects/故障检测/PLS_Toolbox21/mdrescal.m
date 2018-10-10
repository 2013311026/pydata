function rx = mdrescal(x,flag,mx,stdx)
%MDRESCAL Rescales matrix with missing data as specified.
%  Rescales a matrix (x) with missing data indicated by (flag)
%  using means (mx) and standard deviations (stdx) specified.
%  (flag) can be numeric or NaN (flag = [] implies NaN).
%
%I/O:  rx = mdrescal(x,flag,mx,stdx);
%
%  If only three input arguments are supplied then the function
%  will not do variance rescaling, but only vector addition.
%
%I/O:  rx = mdrescal(x,flag,mx);
%
%See also: AUTO, MDAUTO, MDMNCN, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-2000
%By Barry M. Wise
%nbg 11/00 added NaN

if isempty(flag)
  flag = NaN;
end

[m,n]  = size(x);
rx     = ones(m,n)*flag;
if nargin == 4
  for ii=1:n
    if isfinite(flag)
      z = find(x(:,ii)~=flag);
    else
      z = find(isfinite(x(:,ii)));
    end
    rx(z,ii) = (x(z,ii)*stdx(ii))+mx(ii);
  end
else
  for ii=1:n
    if isfinite(flag)
      z = find(x(:,ii)~=flag);
    else
      z = find(isfinite(x(:,ii)));
    end
    rx(z,ii) = x(z,ii)+mx(ii);
  end
end
