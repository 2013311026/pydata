echo on
%RIDGDEMO Demonstrates the ridge and ridgecv functions
% for calculating regression coefficients.

echo off
%Copyright Eigenvector Research, Inc. 1992-98
%Modified November 1993
echo on

% The data set we'll be using to start here is taken from
% Applied Regression Analysis by Draper and Smith.  It is 
% known as the Hald data set.

pause
load ridgdata

% As usual, we need to scale the data.  In this case I'm
% going to chose mean centering, mostly because that is
% what Draper and Smith did.
pause

[mcx,xmns] = mncn(xblock);
[mcy,ymns] = mncn(yblock);

% Now we can use the ridge regression function to form a
% model.  Here I'll choose a maximum value of theta to
% be thetamax = 1 and we'll look at 50 increments of theta
% from 0 to 1.
pause

[b,theta] = ridge(mcx,mcy,1,50);
pause

% The plot that you see is the values of the regression
% coefficients as a function of theta, the ridge parameter.
% The numbers key the lines to each of the coeficients.
% The vertical line is drawn at the optimum theta as 
% determined by the method of Hoerl, Kennard and Baldwin
% as given in Draper and Smith (p 317).  Compare to figure
% 6.4 of Draper and Smith.

pause

% We may wish to zoom in on the area near the optimum theta.
% To do this we just change the input arguments.

[b,theta] = ridge(mcx,mcy,.03,50);
pause

% It is also interesting to use ridge regression on our pls
% data set.  

load plsdata

% This time we'll autoscale the data.

ax = auto(xblock1);
ay = auto(yblock1);

% As a first step, we can use the ridge function
pause

[b,theta] = ridge(ax,ay,.05,20);
pause

% It is also possible to determine the optimum value of
% theta through cross-validation using the ridgecv function.

[b,theta] = ridgecv(ax,ay,.02,20,4);
pause

% So you see that in this case the value of theta that we
% get from cross valadation (.0110) is almost exactly the
% the same as the value we get from the method of Hoerl, 
% Kennard and Baldwin (.0104)
