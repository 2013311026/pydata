function [coeffs,knotspots] = splnfit(x,y,knots,order,plots)
%SPLNFIT Spline fit with specified order and number of knots
%  This function performs a spline fit of bivariate data.
%  The inputs are the data vectors (x) and (y), the number
%  of knots to be used (knots) and the degree of the
%  polynomial to be used (order).  The optional variable (plots)
%  suppresses the generation of a plot when set to 0.  The
%  outputs are the matrix of spline coefficients (coeffs) and
%  the x location of the knots (knotspots). See splnpred for 
%  using the spline model to predict new y values.
%
%I/O: [coeffs,knotspots] = splnfit(x,y,knots,order,plots);
%
%See also: SPL_PLS, SPLSPRED

%Copyright Eigenvector Research, Inc. 1992-98
%Modified BMW 4/94
 
[m,n] = size(x);
% Sort x and y
[x,ind] = sort(x);
y = y(ind);
ks = m/(knots+1);
knotspots = zeros(knots,2);
% Determine knot locations
for i = 1:knots
  k = floor(ks*i);
  knotspots(i,1) = x(k,1)*(k-ks*i+1) + x(k+1,1)*(ks*i-k);
  knotspots(i,2) = k;
end
% Set up matrix of constraints
conmat = zeros(order*knots,(knots+1)*(order+1));
% Determine base unit of constraints matrix coeffs
base = zeros(order,order+1);
base(1,:) = ones(1,order+1);
for i = 2:order
  for j = 1:order+1
    if j >= i
      base(i,j) = base(i-1,j)*(j-i+1);
    end
  end
end
xbase = base;
for i = 1:knots
  for j = 1:order
    for k = 1:order+1
      if k > j;
        xbase(j,k) = base(j,k)*knotspots(i)^(k-j);
      end 
    end
  end
  xind1 = (i-1)*(order+1)+1;
  xind2 = i*(order+1);
  yind1 = (i-1)*order+1;
  yind2 = i*order;
  conmat(yind1:yind2,xind1:xind2) = xbase;
  xind1 = i*(order+1)+1;
  xind2 = (i+1)*(order+1);
  conmat(yind1:yind2,xind1:xind2) = -xbase;
end
%  Get basis set for constraint matrix
cov = conmat'*conmat;
[u,s,v] = svd(cov,0);
basis = v(:,order*knots+1:(knots+1)*(order+1));
%  Set up the matrix of x values and their squares
xmat = zeros(m,(order+1)*(knots+1));
for i = 1:knots+1
  xind1 = (i-1)*(order+1)+1;
  xind2 = i*(order+1);
  if i == 1
    yind1 = 1;
  else
    yind1 = knotspots(i-1,2)+1;
  end
  if i == knots+1
    yind2 = m;
  else
    yind2 = knotspots(i,2);
  end 
  pwr = 0;
  for k = xind1:xind2
    for j = yind1:yind2
      xmat(j,k) = x(j,1)^pwr;
    end
    pwr = pwr+1;
  end
end
%  Project the x matrix onto the basis set and get scores
xscores = xmat*basis;
%  Solve for the coeffs 
c = basis*(xscores\y);
%  Store coefficients and knot locations for output
coeffs = zeros(order+1,knots+1);
for i = 1:knots+1
  coeffs(1:order+1,i) = c((i-1)*(order+1)+1:i*(order+1),1);
end
%  Check plots option and plot if desired
if nargin < 5
  plots = 1;
end
if plots == 1
  plot(x,y,'+r'), hold on
  yfit = xmat*c;
  plot(x,yfit,'-g')
  yk = zeros(knots,1);
  for i = 1:knots
    xpwrs = zeros(1,order+1);
    for j = 1:order+1
      xpwrs(1,j) = knotspots(i,1)^(j-1);
    end
    yk(i,1) = xpwrs*coeffs(:,i); 
  end
  plot(knotspots(:,1),yk,'ob'), hold off
  text(.2,.8,'Circles show knot location','sc')
  s = sprintf('Spline fit using %g knots and polynomials of degree %g',knots,order);
  title(s)
end
knotspots = knotspots(:,1);

