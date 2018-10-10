function [b,ssq,p,q,r,t,u,v] = simpls(x,y,maxlv,xtx,out)
%SIMPLS Partial Least Squares regression via SIMPLS algorithm
%  Inputs are the scaled predictor block (x), scaled
%  predicted block (y), maximum number of latent variables to
%  consider (maxlv). Optional inputs include the covariance of
%  predictors (xtx), and a flag which suppresses screen output
%  [out=0 suppresses output]. Outputs are the matrix of regression
%  vectors or matrices (b), the sum of squares captured (ssq),
%  the x loadings (p), y loadings (q), weights (r), x scores (t),
%  y scores (u), and the basis of x loadings (v).
%
%  The regression matrices are ordered in b such that each
%  ny (number of y variables) rows correspond to the regression
%  matrix for that particular number of latent variables.
%
%I/O: [b,ssq,p,q,r,t,u,v] = simpls(x,y,maxlv,xtx,out);
%
%Example: [b,ssq,p,q,r,t,u,v] = simpls(x,y,10,[],0);
%
%See also: PCR, PLS, MODLGUI
%
%  Note that there are some differences between the SIMPLS 
%  algorithm and the standard NIPALS algorithm. The x scores
%  t are orthonormal and the p are not normalized (i.e. the x variance
%  information is carried in the loads, not the scores).
%  The x matrix inverse can be calculated as rinv = r*t';
%  The x matrix approximation is xhat = t*p';
%  New x scores t are calculated from t = x*r;
%  The sample leverages are lev = diag(t*t' + eye(mx)/mx); 
%  where mx = number of x variables.
%  The estimated leave one out prediction errors are then
%  e = (y-x*b)./(1-lev)

%Copyright Eigenvector Research, Inc. 1997-2000
%Modified nbg 1/98
%Modified bmw 12/98 (added rank check)
%NBG: 10/27/00 NaN/inf and mx~=my check

[mx,nx] = size(x);
[my,ny] = size(y);

if mx~=my                        %nbg 10/27/00, start
  error('Number of rows in X and Y must be the same.')
elseif ~all(all(isfinite([x,y])))
  error('Input (data) can not contain ''NaN'' or ''inf''')
end                              %nbg 10/27/00, end

cmflag  = 0;
if nargin < 4
  if mx > 5*nx
    xtx = x'*x;
    cmflag  = 1;
  end
else
  if ~isempty(xtx)
    cmflag = 1;
  end
end
if nargin < 5
  if nargout > 1
    out = 1;
  else
    out = 0;
  end
end
p = zeros(nx,maxlv);
q = zeros(ny,maxlv);
r = zeros(nx,maxlv);
t = zeros(mx,maxlv);
u = zeros(mx,maxlv);
v = zeros(nx,maxlv);
z = zeros(ny,1);
s = x'*y;
omaxlv = maxlv;
rankx = rank(x);
if rankx < omaxlv
  maxlv = rankx;
  if out == 1
    disp('  ')
    sss = sprintf('Rank of X is %g, which is less than maxlv of %g',maxlv,omaxlv);
    disp(sss);
    sss = sprintf('Calculating %g LVs only',maxlv);
    disp(sss);
  end
end
for lv = 1:maxlv
  if ny > 1
    [eve,eva] = eig(s'*s);
    [meva,ind] = max(diag(eva));
    qq = eve(:,ind);
    rr = s*qq;
  else
    qq = 1;
    rr = s;
  end
  tt = x*rr;
  normtt = norm(tt);
  tt = tt/normtt;
  rr = rr/normtt;
  if cmflag == 1
    pp = xtx*rr;
  else
    pp = x'*tt;
  end
  qq = y'*tt;
  uu = y*qq;
  vv = pp;
  if lv > 1
    vv = vv - v*(v'*pp);
    uu = uu - t*(t'*uu);
  end
  vv = vv/norm(vv);
  s = s - vv*(vv'*s);
  r(:,lv) = rr;
  t(:,lv) = tt;
  p(:,lv) = pp;
  q(:,lv) = qq;
  u(:,lv) = uu;
  v(:,lv) = vv;
end
if ny == 1
  if maxlv ~= 1
    b = cumsum((r*diag(q))');
  else
    b = (r*q)';
  end
else
  b = zeros(ny*omaxlv,nx);
  b(1:ny,:) = q(:,1)*r(:,1)';
  for i = 2:omaxlv
    b((i-1)*ny+1:i*ny,:) = q(:,i)*r(:,i)' + b((i-2)*ny+1:(i-1)*ny,:);
  end
end
if (nargout > 1 | out == 1)
  if cmflag == 1
    ssq = [diag(p'*p)/(sum(diag(xtx))) ...
         diag(q'*q)/(sum(sum(y.^2)))]*100; 
  else
    ssq = [diag(p'*p)/(sum(sum(x.^2))) ...
      diag(q'*q)/(sum(sum(y.^2)))]*100;
  end
  ssq = [(1:omaxlv)' ssq(:,1) cumsum(ssq(:,1)) ssq(:,2) ...
    cumsum(ssq(:,2))];
end
if out == 1
  disp('  ')
  disp('       Percent Variance Captured by PLS Model   ')
  disp('  ')
  disp('           -----X-Block-----    -----Y-Block-----')
  disp('   LV #    This LV    Total     This LV    Total ')
  disp('   ----    -------   -------    -------   -------')
  format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
  for i = 1:omaxlv
    tab = sprintf(format,ssq(i,:)); disp(tab)
  end
  disp('  ')
end
