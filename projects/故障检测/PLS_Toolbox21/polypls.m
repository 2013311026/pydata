function [p,q,w,t,u,b,ssqdif] = polypls(x,y,lv,n)
%POLYPLS PLS regression with polynomial inner-relation.
%  The inputs are the matrix of predictor variables (x),
%  the vector or matrix of the predicted variable (y),
%  the maximum number of latent variables to consider (lv)
%  and the order of the polynomial for the inner-relation
%  (n). Outputs are the x-block loadings (p), the y-block 
%  loadings (q), the x-block weights (w), the x-block
%  scores (t), the y-block scores (u), the matrix of inner-
%  relation coefficients (b) and the variance explained
%  (ssqdif). Use POLYPRED to make predictions with new data.
%
%I/O: [p,q,w,t,u,b,ssqdif] = polypls(x,y,lv,n);
%
%See also: LWRXY, NNPLS, PLS, POLYDEMO, POLYPRED, SPL_PLS

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 11/93
%Checked on MATLAB 5 by BMW

[mx,nx] = size(x);
[my,ny] = size(y);
p = zeros(nx,lv);
q = zeros(ny,lv);
w = zeros(nx,lv);
t = zeros(mx,lv);
u = zeros(my,lv);
b = zeros(n+1,lv);
ssq = zeros(lv,2);
ssqx = sum(sum(x.^2)');
ssqy = sum(sum(y.^2)');
for i = 1:lv
  [pp,qq,ww,tt,uu] = plsnipal(x,y);
  b(:,i) = (polyfit(tt,uu,n))';
  x = x - tt*pp';
  y = y - (polyval(b(:,i),tt))*qq';
  ssq(i,1) = (sum(sum(x.^2)'))*100/ssqx;
  ssq(i,2) = (sum(sum(y.^2)'))*100/ssqy;
  t(:,i) = tt(:,1);
  u(:,i) = uu(:,1);
  p(:,i) = pp(:,1);
  w(:,i) = ww(:,1);
  q(:,i) = qq(:,1);
end
ssqdif = zeros(lv,2);
ssqdif(1,1) = 100 - ssq(1,1);
ssqdif(1,2) = 100 - ssq(1,2);
for i = 2:lv
  for j = 1:2
    ssqdif(i,j) = -ssq(i,j) + ssq(i-1,j);
  end
end
disp('  ')
disp('     Percent Variance Captured by PolyPLS Model   ')
disp('  ')
disp('           -----X-Block-----    -----Y-Block-----')
disp('   LV #    This LV    Total     This LV    Total ')
disp('   ----    -------   -------    -------   -------')
ssq = [(1:lv)' ssqdif(:,1) cumsum(ssqdif(:,1)) ssqdif(:,2)...
cumsum(ssqdif(:,2))];
format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
for i = 1:lv
  tab = sprintf(format,ssq(i,:)); disp(tab)
end
disp('  ')
