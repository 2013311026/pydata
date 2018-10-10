echo off
%LWRDEMO Demonstrates locally weighted regression functions

echo on
%
% This is a demonstration of the LWRPRED and LWRXY functions in
% the PLS_Toolbox.  It uses some process I/O data to build
% locally weighted regression models and compares them to a 
% non-linear PLS model produced by polypls.
%
echo off
%Copyright Eigenvector Research, Inc. 1991-2000
%Modified May 1994
%Modified BMW 3/98
%nbg 11/00 added out=0 to lwrpred and lwrxy
echo on

% Lets start by loading the data

load pol_data

% We now have some calibration data (caldata) for building
% a model and some data we can test it with (testdata).
% We can plot out the calibration data and take a look at it.
pause

echo off;
[m,n] = size(caldata);
[mt,nt] = size(testdata);
plot(1:m,caldata(:,1),1:m,caldata(:,2),'--b')
title('Process Input (solid) and Output (dashed) Data for Calibration')
xlabel('Sample Number (time)')
ylabel('Process Input and Output')
pause
echo on

% What we want to do is build a model that relates the past
% values of the input to the current output.  As usual, we
% will start by scaling the calibration data, and we'll also 
% scale the test data using the same factors.

[acaldata,mcal,scal] = auto(caldata);
stestdata = scale(testdata,mcal,scal);
pause

% Now we can use the writein2 function to rewrite the data files
% into the diagonal format used in Finite Impulse Response (FIR)
% models.  In this case we have to chose how many samples into
% the past we will look.  It turns out that 6 is a good number
% for this data set.

[ucal,ycal] = writein2(acaldata(:,1),acaldata(:,2),6);
[utest,ytest] = writein2(stestdata(:,1),stestdata(:,2),6);

% We can now use the LWRPRED function with the calibration
% data to predict the test data.  In this case we'll use
% 4 latent variables for prediction and the 41 nearest samples
% in the calibration set.  This is going to take a couple
% minutes so hold on.
pause

ypredlwr = lwrpred(utest,ucal,ycal,4,41,0);

% We can also use the LWRXY function, which takes the 
% uses a distance measure that takes the predicted variable
% into consideration.
pause

ypredxy = lwrxy(utest,ucal,ycal,4,41,.4,2,0);

% Now lets form a non-linear pls model and use it to predict
% our test samples and compare.  In this case we'll use
% a second order polynomial for the inner-relation and 
% 4 latent variables for prediction (the order and number of
% lvs was determined previously throught cross-validation).

[pp,qp,wp,tp,up,bp,ssqp] = polypls(ucal,ycal,5,2);
yprednlpls = polypred(utest,bp,pp,qp,wp,5);

% And we can form a linear pls model.

b = pls(ucal,ycal,5);
ypredpls = utest*b(3,:)';

% Now lets rescale and compare our results.

echo off;
sc = 1:451;
sypredlwr = rescale(ypredlwr,mcal(1,2),scal(1,2));
sypredxy = rescale(ypredxy,mcal(1,2),scal(1,2));
syprednlpls = rescale(yprednlpls,mcal(1,2),scal(1,2));
sypredpls = rescale(ypredpls,mcal(1,2),scal(1,2));
sytest = rescale(ytest,mcal(1,2),scal(1,2));
plot(sc,sytest,sc,sytest,'oy',sc,syprednlpls,'-g'), hold on
plot(sc,sypredpls,'--b',sc,sypredxy,'xr')
axis([0 400 5 10])
plot(sc,sypredlwr,'-c')
title('Results from Locally Weighted Regression and Non-Linear PLS Models')
xlabel('Sample Number (time)')
ylabel('Actual and Predicted Outputs')
text(60,6.4,'Actual Output');
text(65,6.1,'Linear PLS Model');
text(70,5.8,'Non-Linear PLS Model');
text(75,5.5,'LWR Model');
text(80,5.2,'LWRXY Model');
plot(10:5:55,ones(10,1)*6.5,'oy',10:5:55,ones(10,1)*6.5,'-y');
plot(15:3:60,ones(16,1)*6.2,'--b');
plot(20:3:65,ones(16,1)*5.9,'-g');
plot(25:3:70,ones(16,1)*5.6,'-c')
plot(30:3:75,ones(16,1)*5.3,'xr')
hold off;
pause
echo on

% This is a bit hard to see, so lets zoom in on the first
% 150 points.

echo off;
plot(sc,sytest,sc,sytest,'oy',sc,syprednlpls,'-g'), hold on
plot(sc,sypredpls,'--b',sc,sypredxy,'xr')
axis([0 150 5 10]);
plot(sc,sypredlwr,'-c')
title('Results from Locally Weighted Regression and Non-Linear PLS Models')
xlabel('Sample Number (time)')
ylabel('Actual and Predicted Output')
text(40,6.5,'Actual Output');
text(45,6.2,'Linear PLS Model');
text(50,5.9,'Non-Linear PLS Model');
text(55,5.6,'LWR Model');
text(60,5.3,'LWRXY Model');
plot(10:3:35,ones(9,1)*6.6,'oy',10:3:35,ones(9,1)*6.6,'-y');
plot(15:3:40,ones(9,1)*6.3,'--b');
plot(20:3:45,ones(9,1)*6.0,'-g');
plot(25:3:50,ones(9,1)*5.7,'-c')
plot(30:3:55,ones(9,1)*5.4,'xr')
hold off;
pause
echo on

% The model prediction error sum of squares can also be calculated.

echo off
lwrerr = sum((sytest - sypredlwr).^2);
nlplserr = sum((sytest - syprednlpls).^2);
plserr = sum((sytest - sypredpls).^2);
lwrxyerr = sum((sytest - sypredxy).^2);
disp('  ')
disp('  Total Sum of Squares Prediction Error')
disp('  Lin PLS     NL-PLS     LWR      LWRXY')
disp([plserr nlplserr lwrerr lwrxyerr])
echo on;

% As you can see, the non-linear PLS and LWR prediction
% errors are very similar, with LWRXY being the best.  
% The linear model prediction error is quite high.
