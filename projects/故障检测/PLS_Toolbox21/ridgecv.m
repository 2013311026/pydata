function [b,thetamin,cumpress] = ridgecv(xblock,yblock,thetamax,divs,split);
%RIDGECV Ridge regression by cross validation
%  This function calculates a ridge regression model and uses
%  cross-validation to determine the optimum value of the ridge
%  parameter theta.  The inputs are the matrix of independent 
%  variables (x), the vector of the dependent variable (y),
%  the maximum value of theta to consider (thetamax),
%  the number of values of theta to test (divs) and the number
%  of times to split and test the data (split).  Outputs are
%  the optimal regression vector (b) defined by the minimum
%  prediction error sum of squares and the value of theta
%  at the minimum PRESS (thetamin).
%
%I/O: [b,theta,cumpress] = ridgecv(x,y,thetamax,divs,split);
%
%See also: CROSSVAL, MODLGUI, PCR, PLS, RIDGE, SIMPLS

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW (graphics) 11/93, 5/95

press = zeros(split,divs+1);
[mx,nx] = size(xblock);
[my,ny] = size(yblock);
if mx ~= my
  error('Number of samples must be the same in both blocks')
end
incr = thetamax/divs;
hfig  = figure;   %nbg 11/00
for i = 1:split
  ind = zeros(mx,1);
  count = 0;
  for j = 1:mx
    test = round((j+i-1)/split) - ((j+i-1)/split);
    if test == 0
      ind(j,1) = 1;
      count = count + 1;
    end
  end
  [a,b] = sort(ind);
  newx = xblock(b,:);
  newy = yblock(b,:);
  calx = newx(1:mx-count,:);
  testx = newx(mx-count+1:mx,:);
  caly = newy(1:mx-count,:);
  testy = newy(mx-count+1:mx,:);
  [m,n] = size(xblock);
  dfs = m - n - 1;
  b = zeros(n,divs+1);
  b(:,1) = calx\caly;
  ridi = diag(diag(calx'*calx));
  for j = 1:divs
    b(:,j+1) = inv(calx'*calx + ridi*j*incr)*calx'*caly;
  end
  for j = 1:divs+1
    ypred = testx*b(:,j);
    press(i,j) = sum(sum((ypred-testy).^2));
  end
  figure(hfig);   %(1) nbg 11/00
  plot(0:incr:thetamax,press(i,:))
  txt = sprintf('PRESS for Test Set Number %g out of %g',i,split);
  title(txt);
  xlabel('Value of theta');
  ylabel('PRESS');
  drawnow
end
pause(2)
cumpress = sum(press);
plot(0:incr:thetamax,cumpress)
title('Cumulative PRESS as a Function of Theta')
xlabel('Value of Theta')
ylabel('PRESS')
drawnow
[a,minlv] = min(cumpress);
thetamin = (minlv-1)*incr;
t = sprintf('Minimum Cumulative PRESS is at theta = %g',thetamin);
disp(t)
ridi = diag(diag(xblock'*xblock));
b = inv(xblock'*xblock + ridi*thetamin)*xblock'*yblock;
plot(b), hold on, plot(b,'o'), plot(0:nx,zeros(1,nx+1),'-g')
s = sprintf('Final Regression Vector for Theta = %g',thetamin);
title(s)
xlabel('Variable Number')
ylabel('Regression Coefficient')
hold off
