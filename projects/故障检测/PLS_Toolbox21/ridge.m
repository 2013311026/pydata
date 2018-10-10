function [b,theta] = ridge(xblock,yblock,thetamax,divs,tf);
%RIDGE Ridge regression by Hoerl-Kennard-Baldwin
%  This function performs ridge regression.  The inputs are
%  the matrix of independent variables (x), the vector of
%  dependent variable (y), the maximum value of theta to 
%  consider (thetamax), and the number of values of theta 
%  to test (divs).  The optional text flag input (tf) allows
%  the user to place the labels on the plot with the mouse
%  when it is set to 1. Outputs are the final regression vector 
%  defined by the best guess value for theta (b) and the best 
%  guess value of theta (theta) by the Hoerl-Kennard method.
%
%I/O: [b,theta] = ridge(x,y,thetamax,divs,tf);
%
%See also: MODLGUI, PCR, PLS, RIDGECV, RIDGEDEMO

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW (graphics) 11/93

incr = thetamax/divs;
[m,n] = size(xblock);
dfs = m - n - 1;
b = zeros(n,divs+1);
b(:,1) = xblock\yblock;
ridi = diag(diag(xblock'*xblock));
dif = xblock*b(:,1)-yblock;
ssqerr = dif'*dif;
theta = n*(ssqerr/dfs)/sum((ridi.^0.5*b(:,1)).^2);
for i = 1:divs
  b(:,i+1) = inv(xblock'*xblock + ridi*i*incr)*xblock'*yblock;
end
plot(0:incr:thetamax,b'); hold on; 
ax = axis;
plot([theta theta],[ax(3) ax(4)],'-g');
hold off; title('Values of Regression Coefficients as a Function of theta');
xlabel('Value of theta');
ylabel('Regression Coefficients');
xcoord = floor(divs/10);
if xcoord == 0
  xcoord = 2;
end
for i = 1:n
  t = sprintf('%g',i);
  text(xcoord*incr,b(i,xcoord+1),t);
end
if nargin == 4
  tf = 0;
end
t = sprintf('theta = %g',theta);
if tf == 0  
  text(.6*thetamax,.8*(ax(4)-ax(3))+ax(3),'Vertical line shows');
  text(.6*thetamax,.75*(ax(4)-ax(3))+ax(3),'best guess for theta');
  text(.6*thetamax,.7*(ax(4)-ax(3))+ax(3),t);
else
  gtext('Vertical line shows best guess for theta')
  gtext(t)
end  
b = inv(xblock'*xblock + ridi*theta)*xblock'*yblock;

