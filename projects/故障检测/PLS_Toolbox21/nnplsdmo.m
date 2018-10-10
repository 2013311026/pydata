echo off
%NNPLSDMO Routine to demonstrate NNPLS.
%  This script demos the NNPLS routine developed by
%  Thomas J. Mc Avoy and distributed by Eigenvector
%  Research, Inc.
%
%See also: NNPLS

%Copyright Eigenvector Research, Inc. 2000
%nbg

echo on
%Demo of the NNPLS fucntion.

load paint

% The data for this demo is described in D. H. Alman and C. G. Pfeifer,
% "Empirical color mixture models", Color Research and Application,
% 12, 210-222 (1987).
% 
% This is a nonlinear data set, from formulation of color paints.
% There are four inputs, the concentrations of colorants (white, 
% black, violet, magenta), and three outputs, the color values   
% (black to white, red to green , yellow to blue). The first 49  
% samples (xcal and ycal) are for training and the last 8 samples
% (xtest and ytest) are for testing. This is a quaternary quartic
% mixture design. (this information is in Areadme)
%                                                               
% Contents of this file (paint.mat):                             
%  Name       Size     Description                               
%  Areadme   25x63     This note                                 
%  xcal      49x4      Colorant concentrations for training data 
%  xtest      8x4      Colorant concentrations for test data     
%  xvars      4x7      Variable names for colorants              
%  y1cal     49x1      Black/white color value for training data 
%  y1test     8x1      Black/white color value for test data     
%  y2cal     49x1      Red/green color value for training data   
%  y2test     8x1      Red/green color value for test data       
%  y3cal     49x1      Yellow/blue color value for training data 
%  y3test     8x1      Yellow/blue color value for test data     
%  ycal      49x3      All color values for training data        
%  ytest      8x3      All color values for test data            
%  yvars      3x11     Variable names for color values

pause

% The user is encouraged to plot and examine the data. Here we will
% mean center the data. (icv) is a vector of cross-validation test
% samples for the NN and (ical) is the compliment vector.

icv            = [24 33 35 37 41 46];               %35:37 are center point replicates
ical           = delsamps([1:size(xcal,1)]',icv)';
[mcxcal,mxcal] = mncn(xcal(ical,:));                %mean center cal X-block
[mcycal,mycal] = mncn(y1cal(ical,:));               %mean center cal Y-block
scxcv          = scale(xcal(icv,:),mxcal);          %center cv X-block
scycv          = scale(y1cal(icv,:),mycal);         %center cv Y-block
scxtest        = scale(xtest,mxcal);                %center TEST X-block

% Now construct the NN-PLS model. (click on the figure to examine
% the results as they are built one factor and one sigmoid at a
% time.

pause

opts           = zeros(3,1);
opts(1)        = 1;            %show plots of inner relations
opts(2)        = 0;            %use default of 6 sigmoids/factor
opts(3)        = 0.00001;       %change PRESS tol from 0.01 to 0.0001

[W,Q,P,NEURAL,ssqdif] = nnpls(mcxcal,mcycal,scxcv,scycv,2,opts);

% This suggests a 2 factor model. So, now use COLLAPSE to
% calculate the final model parameters.

pause

[W12,W23,B2,B3]       = collapse(NEURAL,W,Q,P,2);   %determine final weights and biases

% Now predictions for the TEST set can be made using NNPLSPRD.

pause

ynpred         = nnplsprd(W12,W23,B2,B3,scxtest);   %make predictions with centered test X-block
ynpred         = rescale(ynpred,mycal);             %rescale the centered predicted Y-block
rmsepn         = sqrt(mean((ynpred-y1test).^2));    %estimate prediction error RMSEP

% Next plot the results

pause

echo off
hplt           = zeros(3,1);
hfig           = figure;
hplt(1)        = plot(y1test,ynpred,'ob','markerfacecolor',[0 0 1]); dp, hold on
xlabel('Measured Black/white color value')
ylabel('Predicted Black/white color value')
title('Predicted versus Measured')
axis([0 50 0 50])
text(2,36,sprintf('NN-PLS RMSEP = %1.2f',rmsepn)),  shg
echo on

% These results look pretty good. But it's always good to
% compare to other approaches. So, let's try plain old
% vanilla PLS.
%
% First we'll scale the data.

pause

[mcxcal2,mxcal2] = mncn(xcal);                      %mean center cal X-block
[mcycal2,mycal2] = mncn(y1cal);                     %mean center cal Y-block
scxtest2         = scale(xtest,mxcal2);             %center test X-block

% Now perform cross-validation

pause

figure
crossval(mcxcal2,mcycal2,'sim','vet',3,6);

% Cross-validation suggests using 2 latent variables, but the vaiance
% captured table suggests using only 1. We'll try a 2 LV PLS model
% model using the SIMPLS function. Then we'll make predictions for
% the test set and plot the results.

pause

bpls             = simpls(mcxcal2,mcycal2,2);            %obtian regression vector
yppred           = rescale(scxtest2*bpls(2,:)',mycal2);  %project and rescale predictions
rmsepp           = sqrt(mean((yppred-y1test).^2));       %estimate prediction error

echo off
figure(hfig)
hplt(2)          = plot(y1test,yppred,'rs');
text(2,33,sprintf('PLS RMSEP =    %1.2f',rmsepp))
legend(hplt(1:2),'NN-PLS','PLS', 2)
shg
echo on

% This shows that NN-PLS model performs better than the PLS model. Lastly,
% Let's try a POLY-PLS model.

% Here we'll try a 3 LV PLS model with a 3rd order polynomial inner
% relation.

pause

[p,q,w,t,u,b2]   = polypls(mcxcal2,mcycal2,3,3);         %calibration
y3pred           = rescale(polypred(scxtest,b2,p,q,w,3),mycal2);  %test
rmsep3           = sqrt(mean((y3pred-y1test).^2));       %estimate prediction error

echo off
figure(hfig)
legend off
hplt(3)          = plot(y1test,y3pred,'m^','markerfacecolor',[1 0 1]);
text(2,30,sprintf('POLY-PLS RMSEP = %1.2f',rmsep3))
legend(hplt,'NN-PLS','PLS','POLY-PLS', 2)
shg
echo on

%That ends the NN-PLS demo (NNPLSDMO2).

echo off