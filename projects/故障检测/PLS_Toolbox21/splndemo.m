clc
%SPLNDEMO Demonstrates spline functions and SPL_PLS
echo on
% This script demonstrates the spline functions in the PLS_Toolbox
% including the spline pls function, spl_pls, and the stand alone
% spline fitting function, splnfit.
echo off

%Copyright Eigenvector Research, Inc. 1994-98
%Modified April 1994
%Modified BMW 3/98
echo on

% First we'll load some bivariate data and show how the stand alone
% spline functions work.  The function splnfit can be used
% to fit a spline with user specified degree and number
% of knots to a pair of vectors.  There is no limit to the number
% of knots and spline polynomial degree, however,
% numerical instabilities will occur for very high orders
% or large numbers of knots in some cases.

load splndata
pause

% Let's take a look at the first set of data.

echo off
plot(x,y1,'+r')
title('Data for first spline fit example')
pause
echo on

% I think you'll agree that there is some definite curvature
% here.  Now we'll use the splnfit function to fit a second 
% order spline with with 2 knots to the data. 
pause

echo off
[coeffs,knotspots] = splnfit(x,y1,2,2,1);
pause
echo on

% This was pretty easy.  Lets try a harder one.  First we'll
% plot up the data.
pause

echo off
plot(x,y2,'+r')
title('Data for second spline fit example')
pause
echo on

% This might be a little more difficult, but lets try 2 knots
% and second order to start with.
pause

echo off
[coeffs,knotspots] = splnfit(x,y2,2,2,1);
pause
echo on

% This really doesn't look like we caught all of the curves
% in the data effectively, so lets try adding a couple more
% knots to the spline.  This time we'll use 4 knots and a
% second order spline.
pause

echo off
[coeffs,knotspots] = splnfit(x,y2,4,2,1);
pause
echo on

% This is better, but I still don't like the fit on the left
% end.  In order to make it fit better, we'll go to a third
% order spline and stick with 4 knots.
pause

echo off
[coeff43,knotspot43] = splnfit(x,y2,4,3,1);
pause
echo on

% Alternately, we could have stayed with second order and
% added more knots.  Lets try 8 knots.

echo off
[coeff82,knotspot82] = splnfit(x,y2,8,2,1);
pause
echo on

% This looks over fit to me.  Just for fun, lets look at the
% the two splines together.  We'll use the splnpred function
% and the model parameters from each of the them to get a 
% a plot of the function.
pause

echo off
xnew = (-4:.2:5)';
ypred43 = splnpred(xnew,coeff43,knotspot43,1);
ypred82 = splnpred(xnew,coeff82,knotspot82,1);
echo on

% Now we can plot these on the same figure and compare.
pause

echo off
plot(xnew,ypred43,xnew,ypred82), hold on
plot(xnew,ypred43,'+r',xnew,ypred82,'og'), hold off
title('3rd degree 4 knot spine (+), 2nd degree 8 knot spine (o)')
pause 
echo on

% So these really don't look very much different, the 8 knot
% spline just has slightly more curvature in the middle
% portions.

% Now lets use the spline pls functions with some dynamic data.
% We'll use the same data that that demonstrates the polypls
% function and do some comparisons.  Note: spl_pls is quite
% slow--this might take a few minutes.  If you aren't using
% at least an '040 Mac or 486 PC, you might want to get a cup
% of coffee!
pause

load pol_data
echo off;
[m,n] = size(caldata);
plot(1:m,caldata(:,1),1:m,caldata(:,2),'--b')
title('Process Input (solid) and Output (dashed) Data for Calibration')
xlabel('Sample Number (time)')
ylabel('Process Input and Output')
pause
echo on

% What we want to do is build a model that relates the past
% values of the input to the current output.  As usual, we
% will start by scaling the data.

[acaldata,mcal,scal] = auto(caldata);

% Now we can use the writein2 function to rewrite the data file
% into the diagonal format used in Finite Impulse Response (FIR)
% models.  In this case we have to chose how many samples into
% the past we will look.  It turns out that 6 is a good number
% for this data set.

[ucal,ycal] = writein2(acaldata(:,1),acaldata(:,2),6);
pause

% We can now use the polypls and spl_pls functions to 
% build models that relate the input ucal to the output ycal.
% We must chose the number of latent variables to consider
% and the order of the polynomial to be used in the inner
% relation in the polypls function.  In this case I'll choose
% 5 and 2, respectively.  In the spl_pls function we also
% have to choose the number of knots.  For it I'll choose
% 1 knot and a second degree spline. I'll leave the plot
% option turned on in the spl_pls function so you can see
% the way the spline fits the xblock scores to the yblock
% scores.  We'll also do a linear MLR model just for comparison.

% You might want to go get your coffee now.
pause

echo off
[PP,QP,WP,TP,UP,bp,ssqp] = polypls(ucal,ycal,5,2);
[P,W,T,U,C,cfs,ks,ssq] = spl_pls(ucal,ycal,1,2,3,1);
r = ucal\ycal;
echo on

% The models are now made.  Note how the spl_pls model picks up
% more yblock variance with fewer LVs than the polypls model.
% Now we'll plot up the predictions and take a look;
pause

echo off
ypoly = polypred(ucal,bp,PP,QP,WP,5);    
yspln = splspred(ucal,P,W,C,cfs,ks,3,0); 
ylin = ucal*r;                           
[mu,nu] = size(ucal);
plot(1:mu,ycal,1:mu,ypoly,'--',1:mu,yspln,1:mu,ylin,':y')
hold on,  plot(1:mu,ycal,'or'), hold off
title('Actual and Fitted outputs for calibration data set')
xlabel('Time'), ylabel('Actual or Fitted Output')
text(10,2.25,'Actual Output - circles')
text(20,2,'Linear Model - dotted')
text(30,1.75,'Poly-PLS Model - dashed')
text(40,1.5,'Spline-PLS Model - solid')
echo on

% This is hard to see the fit very well, so lets zoom in on
% the first 150 points.
pause

echo off
axis([0 150 -2.5 2.5])
echo on

% Now lets try it with new data. This is the real test, of course.
% We'd like to think that our model is useful for predicting new
% new data rather than just fitting old data.
pause

echo off
stestdata = scale(testdata,mcal,scal);
[utest,ytest] = writein2(stestdata(:,1),stestdata(:,2),6);
ylint = utest*r;
ypolyt = polypred(utest,bp,PP,QP,WP,4);
ysplnt = splspred(utest,P,W,C,cfs,ks,3,0);
[mu,nu] = size(utest);
plot(1:mu,ytest,1:mu,ypolyt,'--',1:mu,ysplnt,1:mu,ylint,':y')
hold on,  plot(1:mu,ytest,'or'), hold off
title('Actual and Predicted outputs for new data set')
xlabel('Time'), ylabel('Actual or Predicted Output')
text(10,1.1,'Actual Output - circles')
text(20,1,'Linear Model - dotted')
text(30,.9,'Poly-PLS Model - dashed')
text(40,.8,'Spline-PLS Model - solid')
axis([0 450 -0.3 1.2])

pause
echo on

% Once again, this is rather hard to see, so we'll zoom in
% on the first 150 points
pause

echo off
axis([0 150 -0.2 1.2]);
pause
echo on

% Its fairly obvious that the linear model isn't doing too good
% of a job.  The spl_pls model appears to be a little better
% than the polypls model.  Lets put some numbers on this by
% calculating the prediction errors and comparing.

linssq = sum((ytest-ylint).^2);
splnssq = sum((ytest-ysplnt).^2);
polyssq = sum((ytest-ypolyt).^2);

echo off
disp('  ')
disp('  Total Sum of Squares Prediction Error')
disp('   Linear    Poly-PLS   SPL-PLS')
disp([linssq polyssq splnssq])
axis;
echo on
pause

% As you can see, both non-linear models are drastically better than 
% the linear model.  The spl_pls model is almost 10% better than the
% polypls model.
