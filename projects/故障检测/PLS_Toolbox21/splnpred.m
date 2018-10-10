function ypred = splnpred(xnew,coeffs,knotspots,plots);
%SPLNPRED Uses spline from SPLNFIT and new x data to predict new y
%  This function uses the coefficients and knot locations produced
%  by the function SPLNFIT to predict new data. The inputs are  
%  the vector of new x values (xnew), the matrix of spline
%  coefficients (coeffs), and the vector of knot x locations
%  (knotspots). An optional input (plots) can be used
%  to suppress plotting by setting it to 0.  The output is the 
%  estimated y value (ypred) based on the SPLNFIT model.
%
%I/O: ypred = splnpred(xnew,coeffs,knotspots,plots);
%
%See also: SPL_PLS, SPLNFIT

%Copyright Eigenvector Research, Inc. 1992-98
%Modified BMW 4/94

[m,n] = size(xnew);
[order,segs] = size(coeffs);
[knots,nn] = size(knotspots);
if knots ~= segs - 1
  error('Coefficients matrix and number of knot locations not consistant!')
end
ypred = zeros(m,1);
xpwr = [1 zeros(1,order-1)];
for i = 1:m
  xpwr(1,2) = xnew(i,1);
  for j = 3:order
    xpwr(1,j) = xnew(i,1)^(j-1);
  end
  interval = 1;
  if xnew(i,1) < knotspots(1,1)
    ypred(i,1) = xpwr*coeffs(:,1);
  elseif xnew(i,1) > knotspots(knots,1)
    ypred(i,1) = xpwr*coeffs(:,segs);
  else
    while xnew(i,1) > knotspots(interval,1)
      interval = interval + 1;
    end
    ypred(i,1) = xpwr*coeffs(:,interval);
  end
end
if nargin ~= 4
  plots = 1;
end
if plots ~= 0
  plot(xnew,ypred,'+r'), hold on
  knotys = zeros(knots,1);
  for i = 1:knots
    xpwr(1,2) = knotspots(i,1);
    for j = 3:order
      xpwr(1,j) = knotspots(i,1)^(j-1);
    end
    knotys(i,1) = xpwr*coeffs(:,i);
  end
  plot(knotspots,knotys,'ob'), hold off
  text(.2,.8,'Circles show knot locations','sc')
  s = sprintf('Prediction from spline fit using %g knots and polynomials of degree %g',knots,order-1);
  title(s)
end
