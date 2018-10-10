echo off
%POLYDEMO Demonstrates the POLYPLS and POLYPRED functions
echo on
%
% This is a demonstration of the polypls and polypred functions in
% the PLS_Toolbox.  It uses some process I/O data to build a
% nonlinear PLS model and compares it to a linear PLS model.
%
echo off
%Copyright Eigenvector Research, Inc. 1991-98
%Modified bmw 2/94, 2/97
%Checked on MATLAB 5 by BMW
%Modified bmw 3/98
echo on

% Lets start by loading the data

load pol_data

% We now have some calibration data (caldata) for building
% a model and some data we can test it with (testdata).
% We can plot out the calibration data and take a look at it.
pause

echo off
[m,n] = size(caldata);
plot(1:m,caldata(:,1),1:m,caldata(:,2),'--r')
title('Process Input (solid) and Output (dashed) Data for Calibration')
xlabel('Sample Number (time)')
ylabel('Process Input and Output')
pause
echo on

% What we want to do is build a model that relates the past
% values of the input to the current output.  As usual, we
% will start by scaling the data.

[acaldata,mcal,scal] = auto(caldata);
pause

% Now we can use the writein2 function to rewrite the data file
% into the diagonal format used in Finite Impulse Response (FIR)
% models.  In this case we have to chose how many samples into
% the past we will look.  It turns out that 6 is a good number
% for this data set.

[ucal,ycal] = writein2(acaldata(:,1),acaldata(:,2),6);
pause

% We can now use the polypls and regular pls functions to 
% build models that relate the input ucal to the output ycal.
% We must chose the number of latent variables to consider
% and the order of the polynomial to be used in the inner
% relation in the polypls function.  In this case I'll choose
% 5 and 2, respectively.  Lets do the nonlinear model first

[PP,QP,WP,TP,UP,bp,ssqp] = polypls(ucal,ycal,5,2);

% And now the linear model

[B,SSQ,P,Q,W,T,U,BIN] = pls(ucal,ycal,5);

% And we can also do polynomial regression
pause

[um,un] = size(ucal);
upoly = [ucal.^2 ucal ones(um,1)];
polymod = upoly\ycal;

% and of course polynomical pcr

[uu,ss,vv] = svd(ucal'*ucal/(um-1));
uu = ucal*vv(:,1:5);
pcrmod = [uu.^2 uu ones(um,1)]\ycal;
pause

% As you can see, the linear model does not account for as much
% of the variance in the y-block as the nonlinear model.
pause

% Now we will use the polypred and plspred functions with the
% models and compare the results to the actual data.  I'll
% choose 3 latent variables in for each model.  In practice
% we would have to obtain this through cross-validation, but 
% in this case I happen to know that 3 LVs will be about right.

ylin = ucal*B(3,:)';
ynon = polypred(ucal,bp,PP,QP,WP,4);
ypoly = upoly*polymod;
ypcr = [uu.^2 uu ones(um,1)]*pcrmod;
pause

% We could compare the actual and predicted outputs in the 
% scaled space, but insteady lets convert back to the original
% scaling so we have a better idea of what it really looks like.

sylin = rescale(ylin,mcal(1,2),scal(1,2));
synon = rescale(ynon,mcal(1,2),scal(1,2));
syact = rescale(ycal,mcal(1,2),scal(1,2));
spoly = rescale(ypoly,mcal(1,2),scal(1,2));
spcr = rescale(ypcr,mcal(1,2),scal(1,2));
pause

% Now we can plot these up and take a look.

echo off
[m,n] = size(sylin);
plot(1:m,syact,'-r',1:m,syact,'or',1:m,sylin,'--b',1:m,synon,'+m');
axis([0 450 0 14]);
hold on, plot(1:m,spoly,'-g',1:m,spcr,'--r');
title('Fit of Models to Training Data');
xlabel('Sample Number (time)');
ylabel('Observed and Predicted Output');
text(60,13,'Actual Output')
plot(10:3:50,ones(14,1)*13.2,'or',10:3:50,ones(14,1)*13.2,'-r');
text(65,12.4,'Linear Model');
plot(15:3:55,ones(14,1)*12.6,'--b');
text(70,11.8,'Non-Linear PLS')
plot(20:3:60,ones(14,1)*12,'+m');
text(75,11.2,'Non-Linear PCR')
plot(25:3:65,ones(14,1)*11.4,'--r')
text(80,10.6,'Polynomial Regression');
plot(30:3:70,ones(14,1)*10.8,'-g')
hold off
pause
echo on

% The plot might be a little hard to see if you don't have a
% big screen, so lets look at just the first 140 points.
pause

echo off
s = 1:140;
plot(s,syact(1:140),'-r',s,syact(1:140),'or',s,sylin(1:140), ...
'--b',s,synon(1:140),'+m',s,synon(1:140),'-b');
hold on, plot(s,spoly(1:140),'-g',1:140,spcr(1:140),'--r');
title('Fit of Models to Training Data')
xlabel('Sample Number (time)')
ylabel('Observed and Predicted Output')
text(90,5,'Actual Output')
text(92,4.5,'Linear Model')
text(94,4,'Non-Linear PLS')
text(96,3.5,'Non-Linear PCR')
text(98,3,'Polynomial Regression')
plot(70:87,ones(18,1)*5.2,'or',70:87,ones(18,1)*5.2,'-r');
plot(72:89,ones(18,1)*4.7,'--b');
plot(74:91,ones(18,1)*4.2,'+m');
plot(76:93,ones(18,1)*3.7,'--r')
plot(78:95,ones(18,1)*3.2,'-g')
hold off
pause
echo on

% As you can see, the nonlinear models are almost indistinguishabe
% from the observed data while the linear model is off in some
% cases.  In order to quantify this a little better we can 
% calculate the fit error sum of squares.
pause

echo off 
difnon = sum((syact-synon).^2);
diflin = sum((syact-sylin).^2);
difpoly = sum((syact-spoly).^2);
difpcr = sum((syact-spcr).^2);

disp('  ')
disp('  ----Total Sum of Squares Fit Error----')
disp('  Lin PLS    Poly       NL-PCR    NL-PLS')
format = '  %6.2f    %6.2f     %6.2f    %6.2f';
tab = sprintf(format,[diflin difpoly difpcr difnon]); disp(tab)
pause

echo on
% Here we see that all of the non-linear models fit
% the data about as well.  The linear model error
% is definitely larger.

% To see why the nonlinear model works better, lets
% take a look at the x- and y-block scores on the first LV.
% The polynomial fit of the x- and y-block scores is shown
% on the plot.

echo off
plot(T(:,1),U(:,1),'+r'); hold on
pcoeff = polyfit(T(:,1),U(:,1),2);
ppscl = [-3.8:.1:4.8]';
[mpp,npp] = size(ppscl);
ppred = [ppscl.^2 ppscl ones(mpp,1)]*pcoeff';
title('X- vs. Y-Block Scores for First Latent Variable');
xlabel('Score on First X-Block LV');
ylabel('Score on First Y-Block LV');
plot(ppscl,ppred,'-b');
plot([1 2],[-1.5 -1.5],'-b');
text(2.2,-1.6,'Polynomial Fit');
hold off
pause
echo on

% The nonlinearity in this data is apparent in the scores plot.
% The polypls routine uses the polyfit routine in MATLAB to
% fit this curve for the PLS inner relation.

% Now lets see if our model is really predictive by testing
% it on a new data set.  We start by scaling the data and 
% arranging it in the correct form, We then use the polypred
% and plspred functions to make the predictions.  Finally, we
% rescale the prediction to original units.

echo off
stestdata = scale(testdata,mcal,scal);
[utest,ytest] = writein2(stestdata(:,1),stestdata(:,2),6);
ylint = utest*B(3,:)';
ynont = polypred(utest,bp,PP,QP,WP,4);
[myy,nyy] = size(ytest);
ypolyt = [utest.^2 utest ones(myy,nyy)]*polymod;
ypcrt = [(utest*vv(:,1:5)).^2 (utest*vv(:,1:5)) ones(myy,nyy)]*pcrmod;
sylint = rescale(ylint,mcal(1,2),scal(1,2));
synont = rescale(ynont,mcal(1,2),scal(1,2));
syactt = rescale(ytest,mcal(1,2),scal(1,2));
spolyt = rescale(ypolyt,mcal(1,2),scal(1,2));
spcrt = rescale(ypcrt,mcal(1,2),scal(1,2));
echo on

% So lets plot it up and see what we get
pause

echo off
s = 1:451;
plot(s,syactt,'-r',s,syactt,'or',s,sylint,'--b',s,synont,'+m',s,synont,'-b')
axis([0 450 5 10])
hold on, plot(s,spolyt,'-g',s,spcrt,'--r');
title('Results from Non-Linear PLS Model');
xlabel('Sample Number (time)');
ylabel('Observed and Predicted Output');
text(60,6,'Actual Output');
text(65,5.8,'Linear Model');
text(70,5.6,'Non-Linear PLS');
text(75,5.4,'Non-Linear PCR');
text(80,5.2,'Polynomial Regression');
plot(10:3:50,ones(14,1)*6.1,'or',10:3:50,ones(14,1)*6.1,'-r');
plot(15:3:55,ones(14,1)*5.9,'--b');
plot(20:3:60,ones(14,1)*5.7,'+m');
plot(25:3:65,ones(14,1)*5.5,'--r')
plot(30:3:70,ones(14,1)*5.3,'-g')
hold off
pause
echo on

% Once again, this may be a little hard to see on a small screen
% so lets look at the first 140 points.
pause

echo off
plot(1:140,syactt(1:140),'-r',1:140,syactt(1:140),'or',1:140,sylint(1:140), ...
'--b',1:140,synont(1:140),'+m',1:140,synont(1:140),'-b');
hold on, plot(1:140,spolyt(1:140),'-g',1:140,spcrt(1:140),'--r');
title('Results from Non-Linear PLS Model');
xlabel('Sample Number (time)');
ylabel('Observed and Predicted Output');
text(20,7,'Actual Output');
text(22,6.8,'Linear Model');
text(24,6.6,'Non-Linear PLS');
text(26,6.4,'Non-Linear PCR');
text(28,6.2,'Polynomial Regression');
plot(6:18,ones(13,1)*7.1,'or',6:18,ones(13,1)*7.1,'-r');
plot(8:20,ones(13,1)*6.9,'--b');
plot(10:22,ones(13,1)*6.7,'+m');
plot(12:24,ones(13,1)*6.5,'--r');
plot(14:26,ones(13,1)*6.3,'-g');
hold off
pause
echo on

% This time the nonlinear model is sometimes off a little bit,
% but it is much closer than the linear model
pause

echo off
difnonp = sum((syactt-synont).^2);
diflinp = sum((syactt-sylint).^2);
difpolyp = sum((syactt-spolyt).^2);
difpcrp = sum((syactt-spcrt).^2);
echo on

% We can also take a look at the total sum of squares prediction
% error of the various models. We'll include the fit errors 
% calculated above in our table for comparison.
pause

echo off
disp('  ')
disp('Total Sum of Squares Fit and Prediction Error')
disp('  Lin PLS    Poly       NL-PCR    NL-PLS')
format = '  %6.2f    %6.2f     %6.2f    %6.2f';
tab = sprintf(format,[diflin difpoly difpcr difnon]); disp(tab)
tab = sprintf(format,[diflinp difpolyp difpcrp difnonp]); disp(tab)
echo on

% Here we see that even though the NL-PLS didn't fit better
% than the Polynomial, it gives considerably better prediction.
