echo on
%PULSDEMO Demonstrates PLSPULSM for FIR model identification
%
% This is a demonstration of the PLSPULSM function for 
% identification of multi-input single output (MISO) 
% finite impulse reponse (FIR) dynamic models.

echo off

%Copyright Eigenvector Research, Inc. 1991-2000
%Modified April 1994
%Modified BMW 3/98
%nbg 11/00 added echo off/on and changed 

echo on

% First, lets load the data and plot it up.

load pulsdata
echo off
[ns,nv] = size(data);
plot(1:ns,data,1:ns,data(:,1),'+r',1:ns,data(:,2),'+g',1:ns,data(:,3),'ob')
title('Data for pulsedemo--Inputs (+) Output (o)')
xlabel('Sample Number')
ylabel('Value of Input or Output')
echo on

% What you see on the plot is some actual process input/output
% data.  The inputs are a feed rate (bottom line) and a 
% a temperature at a particular location (top line).  The output
% is a temperature at another spot.  We would like to build a
% model that tells us what the output temperature is going to
% be given the past vaules of the feed rate and other temperature.

% We can immediately see that we're going to have to do some
% scaling, since the variables are very different is size.
% Lets start by doing that.
pause

[adata,mx,stdx] = auto(data);
echo off
plot(1:ns,adata,1:ns,adata(:,1),'+r',1:ns,adata(:,2),'+g',1:ns,adata(:,3),'ob')
title('Data for pulsedemo--Inputs (+) Output (o)')
xlabel('Sample Number')
ylabel('Value of Input or Output')
echo on

% In this view of the data we can begin to see how the data
% does appear to be correlated, but the relationship looks
% pretty complex.  Lets see if we can build a model that relates
% the process inputs to the outputs using 'plspulsm'.  First,
% however, there are several decisions we have to make.  We first
% must decide how many past samples we're going to use for each
% of the inputs.  I'm going to chose 15 and 25 for this example.
% Next, we must choose the maximum number of lv to consider. I'll
% choose 5 and set the number of cross-validation splits of
% of the data to be 5.  Finally, the time delays between 
% the inputs and output must be specified.  I'll choose
% 1 unit for each of them.
pause

% We are now ready to use the routine.  Once it starts it will
% rewrite the data files, then use a contiguous block cross-
% validation to determine the best number of latent variables
% to use.  The PRESS plots will be shown for each trial, then
% all the PRESS plots will be shown together.  (Press any key to
% start the function after showing each of these last plots.) 
% The function will finish by showing the coefficients in the
% pulse response vector and the actual and predicted process 
% output based on the 'optimum' model.  Press a key when ready
% to start.
pause

b = plspulsm(adata(:,1:2),adata(:,3),[15 25],5,5,[1 1]);

% So we see that the function chose 2 latent variables.

% We can use the regression vector from the 'plspulsm' function
% on the original data and rescale the result to get a better
% idea of how good the fit is.  In order to do this we need to
% write the data into the correct format using the 'wrtpulse'
% function.  We then multiply by the regression vector b, and
% then use 'rescale' (along with the mean and std. dev. of the
% original output data) to get the data back to the original
% scaling.
pause

[newu,newy] = wrtpulse(adata(:,1:2),adata(:,3),[15 25],[1 1]);
ypred = newu*b;
ypred = rescale(ypred,mx(1,3),stdx(1,3));
yact = rescale(newy,mx(1,3),stdx(1,3));
[ns,nv] = size(newy);
echo off
plot(1:ns,yact,'-g',1:ns,yact,'og',1:ns,ypred,'-r',1:ns,ypred,'+r')
title('Actual (o) and Predicted (+) Output for PLS Pulse Response Model')
xlabel('Sample Number (time)')
ylabel('Temperature')
echo on

pause

% We can also plot the prediction residuals

echo off
plot(1:ns,yact-ypred,1:ns,yact-ypred,'xr'), grid
title('Model Prediction Residuals')
xlabel('Sample Number (time)')
ylabel('Actual - Predicted')
echo on

% So you can see that most of the time the prediction is within
% 50 degrees of the observed temperature.  For this system, this 
% prediction is actually pretty good.
