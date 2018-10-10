echo on
%RPLCDEMO Demonstrates the replace function 
% for replacing variables in PCA and PLS models. 

echo off
%Copyright Eigenvector Research, Inc. 1992-98
%Modified April 1994
%Modified BMW 3/98
echo on 

% In order to start out demonstration we'll load some process
% data into memory.  This data set will be divided into a
% test set and a calibration set.

load repdata

% The data set we've just loaded consists of 20 process temperatures
% and 1 level measurement.  We can plot the calibration set to
% see what it looks like.
pause

echo off
subplot(211)
plot(cal(:,1:20))
title('Data for Replace Demo')
xlabel('Sample Number (time)')
ylabel('Temperature')
subplot(212)
plot(cal(:,21))
title('Data for Replace Demo')
xlabel('Sample Number (time)')
ylabel('Tank Level')
pause
echo on

% Now lets build a PCA model of this data.  As usual, we'll
% scale the data first, this time using autoscaling.  Then
% we'll form the PCA model with the scaled data.  The PCA plots
% will be omitted this time. For this data set 7 is a pretty 
% good number, so we will set the PCA function to calculate
% 7 PCs.

[acal,mcal,stdcal] = auto(cal); 
[scores,loads,ssq,res,q,tsq] = pca(acal,0,0,7);
pause

% Now lets take a look at the Q residuals of the test set
% using the model from the calibration set.  First we have to 
% scale the data, then calculate the residual. 

stest = scale(test,mcal,stdcal);

echo off
clf
res = sum(((stest*(eye(21)-loads*loads')).^2)');
plot(1:54,res,[1 54],[q q])
title('New Sample Residuals with 95% Limits from Original Model')
xlabel('Sample Number (time)')
ylabel('Q Residual')
pause
echo on

% Hopefully you noticed that right near the end of the period
% the Q residual went over the 95% limit and stayed there.
% We can determine the reason by calculating and ploting the
% raw residuals.
pause

resmat = stest*(eye(21)-loads*loads');

echo off
plot(1:21,resmat(51:54,:)','-b',[1 21],[0 0],'-g')
title('Residuals for Last 4 Samples of Test Data')
xlabel('Variable Number')
ylabel('Residual')
pause
echo on
 
% As you can see, the residual on the fifth variable is very
% large, which is an indication that the sensor has failed.
% The failure of this sensor has also skewed the residuals on
% many of the other sensors, particulary the ones that are
% highly correlated with it. So, now lets use the replace
% function and see what the residuals would look like if we
% replaced the values from the bad sensors with the value that
% is most consistant with the PCA model we have used. 
pause

rm = replace(loads,5);
reptest = stest*rm;
repmat = reptest*(eye(21)-loads*loads');

echo off
plot(1:21,repmat(51:54,:)','-b',[1 21],[0 0],'-g')
title('Residuals after Replacement of Variable 5')
xlabel('Variable Number')
ylabel('Residual')
pause
echo on

% As you can see, the residual on variable 5 is now zero, but
% the residuals on the other sensors have a much more normal
% looking pattern than they did before.

% Now lets compare this to the results we would obtain if we
% calculated a whole new model leaving the bad variable out,
% instead of just replacing the bad variable with the PCA
% based estimate.  As before, we will choose 7 PCs for the
% the model.
pause

[scores,nloads,ssq,res,q2,tsq] = pca([acal(:,1:4) acal(:,6:21)],0,0,7);
ntest = [stest(:,1:4) stest(:,6:21)];
nresmat = ntest*(eye(20)-nloads*nloads');

echo off
plot(1:20,nresmat(51:54,:)','-b',[1 20],[0 0],'-g')
xlabel('Variable Number')
ylabel('Residual')
hold on
pause
echo on

% Except for the "missing variable 5", these residuals look
% suspiciously like the residuals from the last plot.
% So lets compare these to the residuals from the replacement
% method by plotting them over the top.
pause

echo off
plot([repmat(51:54,1:4) repmat(51:54,6:21)]','--r')
title('Residuals on New Model and Old Model with Replacement')
hold off
pause
echo on

% As you can see, this shows that the residuals are esentially
% the same using either method.  In fact, we have determined
% that in the noise-free case where data is truly rank deficient
% the results are identical.  In real world cases this is an
% approximation but a very close one.
  
% But now lets get to the real reason that you might
% want to replace the values from sensors that have been
% identified as bad.  We also have some data available from
% a period when an additional sensor failed.  So in this new data
% sensor 5 will continue to be bad and then another sensor will
% fail sometime during the period. So first, lets scale the
% data and calculate the residual on the original model.

pause
stest2 = scale(test2,mcal,stdcal);
res2 = sum(((stest2*(eye(21)-loads*loads')).^2)');

echo off
plot(1:288,res2,[1 288],[q q])
title('New Sample Residuals with Limits from Original Model')
xlabel('Sample Number (time)')
ylabel('Q Residual')
pause
echo on

% The failure is very hard to see in this plot.  Can you find it?
% It is at sample 155.  Now lets see what the residual plot looks
% like after the sensor that we already know is bad has been
% corrected for.

pause
rstest2 = stest2*rm;
res2 = sum(((rstest2*(eye(21)-loads*loads')).^2)');

echo off
plot(1:288,res2,[1 288],[q q])
title('New Corrected Sample Residuals with Limits from Original Model')
xlabel('Sample Number (time)')
ylabel('Q Residual')
pause
echo on

% I believe you would find this much easier to see!
