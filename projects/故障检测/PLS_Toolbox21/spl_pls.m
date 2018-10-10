function [P,W,T,U,C,cfs,ks,ssq] = spl_pls(x,y,knots,deg,lv,plots)
%SPL_PLS PLS regression with spline inner-relation
%  The inputs the x-block data (x), y-block data (y), the number 
%  of knots to use in the spline (knots), the degree of the spline
%  (deg), the number of latent variables to consider (lv) and the
%  optional variable (plots) which suppresses all plots when set 
%  to 0.  The outputs are the x-block loadings (P), the x-block
%  weights (W), x-block scores (T), y-block scores (U), inner 
%  coefficients (C), spline coefficients (cfs), knot locations 
%  (ks) and the amount of variance captured by the model (ssq).
%
%I/O: [P,W,T,U,C,cfs,ks,ssq] = spl_pls(x,y,knots,deg,lv,plots);
%
%See also: LWRXY, NNPLS, POLYPLS, PLS, SPLSPRED, SPLNDEMO

%Copyright Eigenvector Research, Inc. 1992-98
%Modified BMW 4/94

if nargin == 5
  plots = 1;
end
[mx,nx] = size(x);
[my,ny] = size(y);
P = zeros(nx,lv);
C = zeros(ny*lv,lv);
W = zeros(nx,lv);
T = zeros(mx,lv);
U = zeros(my,lv);
S = zeros(my,lv);
cfs = zeros(deg+1,(knots+1)*lv);
ks = zeros(knots,lv);
ssqdif = zeros(lv,4);
E = x;
F = y;
totssqx = sum(sum(x.^2));
totssqy = sum(sum(y.^2));
clc
for i = 1:lv
  s = sprintf('Now working on Latent Variable number %g.',i);
  disp(s)
  %  Get starting set of vectors from linear PLS
  sd = std(F);
  [ms,ns] = max(sd);
  u = F(:,ns);
  w = (u'*E)';
  w = w/norm(w);
  t = E*w;
  dif = 1;
  count = 0;
  while dif > 1e-10
    count = count+1;
    % Fit spline to x- and y-block scores t and u
    [coeffs,knotspots] = splnfit(t,u,knots,deg,plots);
    if plots == 1
      s = sprintf('Score on X-block latent variable %g',i);
      xlabel(s)
      s = sprintf('Score on Y-block latent variable %g',i);
      ylabel(s)
	  drawnow
    end
    sa = splnpred(t,coeffs,knotspots,0);
    c = (sa'*F)';
    c = c/norm(c);
    u = F*c/(c'*c);
    %  Calculate the weights
    for j = 1:nx
      vk = norm(t)/norm(x(:,j));
      u1 = splnpred(x(:,j)*vk,coeffs,knotspots,0);
      u2 = -splnpred(-x(:,j)*vk,coeffs,knotspots,0);
      r1 = u'*u1/(norm(u)*norm(u1));
      r2 = u'*u2/(norm(u)*norm(u2));
      w(j,1) = max([r1 r2])*std(x(:,j));
    end
    w = w/norm(w);
    tnew = E*w;
    dif = norm(tnew-t)/norm(t);
    s = sprintf('On Latent Variable %g, iteration %g',i,count);
    disp(s)
    s = sprintf('the change in the scores vector is %g',dif);
    disp(s)
    t = tnew;
    if count > 20
      dif = 10e-12;
      disp('Algorithm failed to converge after 50 iterations');
    end
  end
  p = (t'*E/(t'*t))';
  P(:,i) = p;
  E = E - t*p';
  T(:,i) = t;
  U(:,i) = u;
  S(:,i) = sa;
  W(:,i) = w;
  cc = (S(:,1:i)\y)';
  C((i-1)*ny+1:i*ny,1:i) = cc; 
  F = y - S(:,1:i)*cc';
  if plots == 1
    plot(y), hold on, plot(S(:,1:i)*cc','-b'), hold off
    s = sprintf('Actual data and fit after %g latent variables',i);
    title(s)
	drawnow
  end
  ssqx = sum(sum(E.^2));
  ssqy = sum(sum(F.^2));
  ssq(i,2) = (1 - (ssqx/totssqx))*100;
  ssq(i,4) = (1 - (ssqy/totssqy))*100;
  iy2 = (knots+1)*i;  iy1 = iy2-knots;
  cfs(1:deg+1,iy1:iy2) = coeffs;
  ks(:,i) = knotspots;
end
home
ssq(1,1) = ssq(1,2);
ssq(1,3) = ssq(1,4);
for i = 2:lv
  ssq(i,1) = ssq(i,2) - ssq(i-1,2);
  ssq(i,3) = ssq(i,4) - ssq(i-1,4);
end
disp('  ')
disp('      Percent Variance Captured by SPL_PLS Model')
disp('  ')
disp('             ----X-Block------   ----Y-Block------')
disp('      LV#    This LV    Total    This LV    Total ')
disp([(1:lv)' ssq])
