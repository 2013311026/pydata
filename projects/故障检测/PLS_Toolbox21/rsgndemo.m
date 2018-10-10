echo on
%RSGNDEMO Demonstrates PLSRSGN and PCA for use in MSPC
%  This is a demonstration of the PLSRSGN and PCA functions
%  that shows how they can be used for multivariate statistical
%  process control (MSPC) purposes.

echo off
%Copyright Eigenvector Research, Inc. 1992-98
%Modified April 1994
%Checked BMW 3/98
echo on

% Lets start by loading the pcadata file.

load pcadata

% Before we use the PLSRSGN function, lets do a little
% PCA modelling so we'll have something to compare the 
% results to.  First, of course we have to scale the data.
pause

[apart1,part1means,part1stds] = auto(part1);

% Now lets make a PCA model of the data.  We will choose
% 5 principal components (based on previous experience).
pause

[scores,loads,ssq,res,q,tsq] = pca(apart1,0,0,5);

% Now we can plot the residuals matrix from the PCA model
% and see what it looks like.
pause

echo off
plot(apart1*(eye(10)-loads*loads'))
title('PCA Model Residuals for Each Sample')
xlabel('Sample Number')
ylabel('Residual')
pause
echo on

% So now that we've seen how the PCA residuals look, lets calculate
% the PLS equivilent of the PCA (I - PP') matrix using the
% 'plsresgen' function.  We'll use 4 latent variables.  When the
% function runs you will see the results of the PLS modeling
% for each variable.  Hit a key when you are ready.
pause

coeff = plsrsgn(apart1,4);

% Now that we have the coeficient matrix, lets calculate and
% plot the residuals.  Take one last look at the PCA residuals
% before we plot the PLS residuals.  Ready?
pause

echo off
plot(apart1*coeff)
title('PLS Model Residuals for Each Sample')
xlabel('Sample Number')
ylabel('Residual')
pause
echo on

% The PLS residuals look quite a bit bigger don't they?  Well, looks
% can be somewhat decieving.  The thing about the PLS residuals is
% that a change in the value of a variable causes the residual for 
% that variable to change by an equal amount.  In PCA the residual
% will change by a much smaller amount.  In fact, the amount that it
% will change is equal to the inverse of the diagonal elements of
% (I - PP').  
pause

% Using this information we can now calculate detection
% limits for changes on individual variables.  For now I'm going to
% do crude detection limits, and say that the limit is equal to 2
% standard deviations in the residuals.  (This is about what it would
% be if you looked at sample set sizes of 20.  In order to do this
% accurately you would have to use f- and t-test limits)  We will   
% calculate the limits for the PLS residuals directly, and calculate
% and scale the PCA residual limits to be on the same scale as the 
% PLS residuals.
% Press a key when ready.
pause

plslims = 2*std(apart1*coeff);
scale = diag(inv(diag(diag(eye(10)-loads*loads'))));
pcalims = (2*std(apart1*(eye(10)-loads*loads'))).*scale';

echo off
plot(1:10,pcalims,1:10,plslims,1:10,pcalims,'ob',1:10,plslims,'+b')
title('Detection Limits for PCA (o) and PLS (+) Models')
xlabel('Variable Number')
ylabel('Detection Limit')
pause
echo on

% As you can see the PLS detection limits are tighter than the PCA
% detection limits.  We can also use the scaling factors calculated
% by 'auto' to determine the detection limits in the original variable
% units, which in this case is degrees C. Hit a key when ready.
pause

splslims = plslims.*part1stds;
spcalims = pcalims.*part1stds;

echo off
plot(1:10,spcalims,1:10,splslims,1:10,spcalims,'ob',1:10,splslims,'+b')
title('Detection Limits for PCA (o) and PLS (+) Models')
xlabel('Variable Number')
ylabel('Detection Limit in Degrees C')
pause
echo on

% For some of the variables the detection limit is much better than
% for others.  This depends on how highly correlated the variables
% are.  Variables which are more highly correlated with other variables
% have smaller detection limits.

% If you would like to find out more about these methods please
% see the reference in the PLS_Toolbox Manual.  Also, the PLS
% residuals generating matrix can be optimized by using the 
% PLSRSGNCV routine which uses cross-validation to determine
% the number of latent variables to use in each of the PLS models.
