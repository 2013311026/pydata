echo on
%CRDEMO Demonstrates CR function for continuum regression (CR)
%  This script illustrates continuum regression using the method
%  of de Jong, Wise and Ricker.

echo off
%Copyright Eigenvector Research, Inc. 1992-98
%Modified May 1994
%Modified April, 1998
echo on

% The data we are going to work with is from a Liquid-Fed
% Ceramic Melter process. The variables are temperatures
% in the molten glass tank and the tank level.
%
% Lets start by loading and plotting the data.  Hit a key when
% you are ready.
pause

load plsdata

echo off
plot(xblock1)
title('X-block data for Continuum Regression Demo')
xlabel('Sample Number')
ylabel('Temperature')
pause
echo on

% You can probably already see that there is a very regualar
% variation in the data.  When you see the level plotted, you
% will know why.
pause

echo off
plot(yblock1)
title('Y-Block data for Continuum Regression Demo')
xlabel('Sample Number')
ylabel('Level')
pause
echo on

% Yes that's right, the level correlates with temperature.  Now
% lets use that fact to build a PLS model that uses temperature
% to predict level.  Lets start by mean centering the data.

[mx,mnx] = mncn(xblock1);
[my,mny] = mncn(yblock1);

% Now that the data is scaled we can use the POWERPLS routine 
% to develop a calibration. We'll also make some models using 
% PCR, PLS and MLR and compare them to the CR models.
% We will cross validate over the region of powers of 1/2 to
% 1/8. (From previous tests, I've observed that the best models
% for this problem lie in this range.) Because this is time
% series data, we will use block cross validation, i.e. 
% contiguous blocks of data will be used as test sets.
% We will start by calculating the CR models, using a maximum
% of 5 latent variables. While we're at it, we'll also determine
% the cross validation error on an MLR model.
pause

echo off
powers = 10.^(-1:.05:1); 
[press,fiterr,minlvp,b] = crcvrnd(mx,my,6,5,15,powers,1);
echo on

% Just in case that PRESS surface when by too fast, you
% can see it again here. We've also added the fit error
% surface so you can see what the fit is doing. Notice that
% the fit error declines as you go towards more LVs or towards
% the MLR side of the continuum. You can use the buttons in
% the upper right hand corner of the plot to get different
% views of the surfaces.

echo off
surf(powers,1:15,press'/5)
set(gca,'Xdir','reverse')
set(gca,'Xscale','log')
set(gca,'Ydir','reverse')
title('Cumulative PRESS vs. Number of LVs and Power')
ylabel('Number of Latent Variables')
zlabel('PRESS and Fit Error')
hold on
surf(powers,1:15,fiterr')
hold off
highorb
pause
echo on

% It is also interesting to look at the ratio of the PRESS
% to the fit error. Recall that a model with PRESS more than
% about 20% more than fit error is tending towards overfit.

echo off
surf(powers,1:15,(press'/5)./fiterr')
set(gca,'Xdir','reverse')
set(gca,'Xscale','log')
set(gca,'Ydir','reverse')
title('Cumulative PRESS vs. Number of LVs and Power')
ylabel('Number of Latent Variables')
zlabel('PRESS/Fit Error')
highorb
pause
echo on

% Finally, lets look at the prediction error surface and see
% if it looks anything like the PRESS surface. Here it is as
% a surface plot. We see it that it has the same general shape
% as the cross-validation surface. 

echo off
b = cr(mx,my,15,powers);
xs = scale(xblock2,mnx);
ys = scale(yblock2,mny);
ypred = xs*b';
ydif = ypred-ys(:,ones(615,1));
ydif = sum(ydif.^2);
ymat = reshape(ydif,15,41);
surf(powers,1:15,ymat)
set(gca,'Xdir','reverse')
set(gca,'Xscale','log')
set(gca,'Ydir','reverse')
title('Prediction PRESS on Test Data Set')
ylabel('Number of Latent Variables')
zlabel('Prediction PRESS')
highorb
pause
echo on

% Now lets look at the cross-validation PRESS and prediction
% PRESS side by side. We see that the minimums are not in
% exactly the same places, but generally the trends are the
% same. 

echo off
close(gcf)
subplot(1,2,1)
pcolor(powers,1:15,press')
set(gca,'xscale','log')
set(gca,'xdir','reverse')
set(gca,'ydir','reverse')
xlabel('Continuum Parameter')
ylabel('Number of LVs')
title('Cross Validation PRESS Surface')

subplot(1,2,2)
pcolor(powers,1:15,ymat)
set(gca,'xscale','log')
set(gca,'xdir','reverse')
set(gca,'ydir','reverse')
xlabel('Continuum Parameter')
ylabel('Number of LVs')
title('Prediction PRESS Surface')

[mcv,indcv] = min(press);
[mcv2,indcv2] = min(mcv);
disp(sprintf('The minimum RMSECV was %g at a power of %g and %g LVs',...
             sqrt(mcv2/(5*300)),powers(indcv(indcv2)),indcv2))
             
[mcv,indcv] = min(ymat');
[mcv2,indcv2] = min(mcv);
disp(sprintf('The minimum RMSEP was %g at a power of %g and %g LVs',...
             sqrt(mcv2/(200)),powers(indcv(indcv2)),indcv2))

pause
echo on

% Note that if you run this a few times you may get slightly
% different cross-validation results because of the cross-validation
% is done with random test sets.

echo off
pause
close(gcf)
clear b mcv mny press xs ymat      
clear fiterr mcv2 mx vars yblock1 ypred     
clear indcv minlvp my xblock1 yblock2 ys        
clear indcv2 mnx powers xblock2 ydif
