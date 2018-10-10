echo on
%PLSDEMO Demonstrates PLS and PCR functions
%
%  This demonstration illustrates the use of the PLS and
%  PCR functions in the PLS_Toolbox.

echo off
%Copyright Eigenvector Research, Inc. 1992-98
%Modified 6/94 BMW
%Modified 3/98 BMW
echo on

% The data we are going to work with is from a Liquid-Fed 
% Ceramic Melter (LFCM).  We will develop a model that related
% temperatures in the molten glass tank to the tank level.
% Lets start by loading and plotting the data.  Hit a key when
% you are ready.
pause

echo off
load plsdata
subplot(2,1,1)
plot(xblock1);
title('X-block Data (Predictor Variables) for PLS Demo');
xlabel('Sample Number');
ylabel('Temperature (C)');
subplot(2,1,2)
plot(yblock1)
title('Y-Block Data (Predicted Variable) for PLS Demo');
xlabel('Sample Number');
ylabel('Level (Inches)');
echo on

% You can probably already see that there is a very regualar
% variation in the temperature data and that it appears to
% correlate with the level data. This is because there is
% steep temperature gradient in the molten glass, and when
% the level changes, glasses of different temperatures pass
% by the location of the thermocouples.
pause

% Lets use the fact that temperature correlates with
% level to build PLS and PCR models that uses temperature
% to predict level.  We will start by deleting some samples
% that we know to be outliers then mean-centering the data.
% Here mean-centering makes sense because all of the variables
% are of the same type, and we have reason to expect that 
% the temperatures with the most variance will also be the
% most predictive for level.
pause

[mxblock1,mx] = mncn(delsamps(xblock1,[73 167 188 278 279]));
[myblock1,my] = mncn(delsamps(yblock1,[73 167 188 278 279]));

% Now that the data is scaled we can use the PLS and PCR routines
% to make a calibration.  Lets start by using all the data to 
% make models and see how variance they capture.  We'll also 
% make a model using MLR and compare it to the PLS  and PCR models.
pause

bpls = pls(mxblock1,myblock1,10);
bpcr = pcr(mxblock1,myblock1,10);
mlrmod = mxblock1\myblock1;
pause

% Take a close look at the variance captured by the PLS and PCR
% models. Notice that for any particular number of LVs or PCs
% that the PLS model always captures just a bit more Y-Block
% (predicted variable) variance while the PCR model always
% captures just a bit more X-Block (predictor variable)
% variance. This is because the principal components 
% decomposition of the X-Block in PCR captures the maximum amount
% of variation that can be explained with linear factors without
% regard to how well they correlate with the Y-Block (in this
% case they do correlate quite well). PLS, on the other hand,
% tries to capture more Y-Block variance as well as describing
% X-Block variance. Thus, PLS always gets more Y-Block variance
% and less X-Block variance than PCR.
pause

% We can also see from the variance captured by the PLS  and
% PCR models that 1 latent variable or principal component
% is pretty good and anything after 4 doesn't really add much.  
% However, we really need to cross validate to determine the 
% optimum number of latent variables and principal components.
% For this we will use the CROSSVAL function, which can be
% used to cross-validate PCA, PCR and PLS models using a
% variety of methods. In our case, we'll divide the data into
% contiguous blocks during the cross-validation. The reason  
% for doing this is that the data is serially correlated, 
% so we should split it into contiguous blocks rather than
% selecting a test set that was drawn from within the training
% data. This method largely avoids the problem of having the
% noise in the test set be correlated with the noise in the
% training set. 

pause

% Before we use CROSSVAL we must decide how many 
% times to rebuild and test the model. I'll choose 10 since
% it is reasonable to expect that any disturbance in this
% system would have died away after 30 samples. The maximum
% number of LVs and PCs is set to 20 since this is the maximum
% number of PCs we can have in a data set with 20 variables.  
% Once the function runs we will plot up the PRESS values
% as a function of number of PCs or LVs.
pause

[plspress,plscumpress] = crossval(mxblock1,myblock1,'sim','con',20,10);
[pcrpress,pcrcumpress] = crossval(mxblock1,myblock1,'pcr','con',20,10);

echo off
subplot(2,2,1)
plot(plspress','-o')
xlabel('Number of LVs')
title('PLS Individual PRESS Curves')
ylabel('PRESS')
subplot(2,2,2)
plot(plscumpress,'-o')
xlabel('Number of LVs')
title('PLS Cumlative PRESS Curve')
ylabel('PRESS')
subplot(2,2,3)
plot(pcrpress','-o')
xlabel('Number of PCs')
title('PCR Individual PRESS Curves')
ylabel('PRESS')
subplot(2,2,4);
plot(pcrcumpress,'-o')
xlabel('Number of PCs')
title('PCR Cumlative PRESS Curve')
ylabel('PRESS')
echo on

% Based on the PRESS curves, it looks like 4 LVs would be
% optimal for PLS. However, experience has taught us that
% if the decrease in PRESS isn't at least 2% for adding an
% a factor, then we should back up. Thus, a 3 LV model looks
% good for PLS. We might also reach the same conclusion by
% looking at the variance captured table for PLS. Note that 
% 4th LV captures only a very small amount of variance in y. 

% For PCR, it is a little more problematic. Note that the
% PRESS values bounce around befor taking a drop at 6, then
% they bounce around some more. This behavior is typical of
% PCR because the factors aren't determined with regard to y,
% they just capture variance in x. In this case, it seems 
% logical to select the first minimum after the big drop, so
% a 6 PC model will be selected. Again, the variance captured
% table might lead you to the same conclusion as the 6th PC
% is the last one to capture more than 1% of the y variance.
pause

% By plotting the regression vector we can see what variables
% were important in predicting the level.  We can also compare
% this to the MLR model.
pause

echo off
subplot(1,1,1)
plot(bpls(3,:),'-+b'), hline(0), hold on
plot(bpcr(6,:),'-og')
plot(mlrmod,'-*c'), hold off
title('PLS (+), PCR (o) and MLR (*) Regression Vector Coefficients For Level Prediction');
xlabel('Variable Number');
ylabel('Coefficent');
pause
echo on

% Notice how the MLR model is more "spikey". This "ringing"
% in the coefficients is typical of models identified with
% MLR when there is a great deal of correlation structure in
% the data, as we have here.

% Now lets use the regression vectors to calculate the fitted
% level to the training (calibration) data and compare it to 
% the actual level.
pause

ypls = mxblock1*bpls(3,:)';
ypcr = mxblock1*bpcr(6,:)';
ymlr = mxblock1*mlrmod;
sypls = rescale(ypls,my);
sypcr = rescale(ypcr,my);
symlr = rescale(ymlr,my);

echo off
s = 1:295;
plot(s,sypls,'-y',s,sypls,'+y'), hold on
plot(s,sypcr,'-g',s,sypcr,'og')
plot(s,symlr,'-c',s,symlr,'*c')
plot(s,delsamps(yblock1,[73 167 188 278 279]),'-xr'), hold off
title('Actual (x) and Fitted Level by PLS (+), PCR (o) and MLR')
xlabel('Sample Number');
ylabel('Level (Inches)');
pause
echo on

% This looks pretty good, but lets try the models with a new data
% set to see how they will work for that.  We start by scaling the
% new data using the same factors we used to scale the original
% data.
pause

sxblock2 = scale(xblock2,mx);
syblock2 = scale(yblock2,my);

% Now we just multiply the new xblock by the regression vectors
% to get the new prediction.  After rescaling we can compare the
% predicted and actual data.
pause

newypls = sxblock2*bpls(3,:)';
newypcr = sxblock2*bpcr(6,:)';
newymlr = sxblock2*mlrmod;
sypls = rescale(newypls,my);
sypcr = rescale(newypcr,my);
symlr = rescale(newymlr,my);

echo off
s = 1:200;
plot(s,sypls,'-y',s,sypls,'+y'), hold on
plot(s,sypcr,'-g',s,sypcr,'og')
plot(s,symlr,'-c',s,symlr,'*c')
plot(s,yblock2,'-r',s,yblock2,'xr'), hold off
title('Actual (x) and Predicted Level by PLS (+), PCR (o) and MLR')
xlabel('Sample Number');
ylabel('Level (Inches)');
pause
echo on

% We can also calculate the total sum of squared prediction error
% for the PLS, PCR and MLR models as follows:

echo off
plsssq = sqrt(mean((yblock2-sypls).^2));
pcrssq = sqrt(mean((yblock2-sypcr).^2));
mlrssq = sqrt(mean((yblock2-symlr).^2));

disp('  PLS error PCR error MLR error'), 
disp([plsssq pcrssq mlrssq])
echo on

% So here we see that the PLS and PCR models are slightly
% better than the MLR model, as expected.
