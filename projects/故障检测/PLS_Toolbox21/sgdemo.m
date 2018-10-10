echo off, clc, hold off
%SGDEMO Demonstrates Savitsky-Golay smoothing and derivatives
echo on
% This script demonstrates the Savitsky-Golay smoothing and
% derivative routine, SAVGOL, from the PLS_Toolbox. Many
% thanks to Sijmen de Jong for the original Savitsky-Golay
% code!
echo off

%Copyright Eigenvector Research, Inc. 1992-98
%Modified April 1994
echo on

% Imagine for a moment that you measure the signal shown
% on the plot.

echo off
scl = (0:.1:20);
yt = scl.*sin(scl)/20;
y = yt + scl.*randn(size(scl))/100;
plot(scl,y,'-g'), hold on, text(5,1.35,'Measured Signal')
plot([2 4],[1.35 1.35],'-g'), xlabel('Time in Seconds')
ylabel('Signal'), 
title('Example of Savitsky-Golay Smoothing')
pause
echo on

% It is apparent that there is a general sinusoidal trend
% to this signal with superimposed noise. We can use
% Savitsky-Golay smoothing to get an estimate of the
% "true" signal. We will use a window of 21 points and
% a second order polynomial for the smooth of the signal, y.

y0 = savgol(y,21,2,0);

% We can now plot this signal and see what it looks like

echo off
plot(scl,y0,'-b'), text(5,1.15,'Smoothed Signal')
plot([2 4],[1.15 1.15],'-b')
pause
echo on

% As you can see, this looks much better. Because we
% created the data, we also have the opportunity to
% look at the "true" signal and see how it compares
% to the smooth.

echo off
plot(scl,yt,'-r'), text(5,0.95,'True Signal')
plot([2 4],[.95 .95],'-r')
pause
echo on

% So you can see that the true signal and the smooth are
% fairly close.

% We might also be interested in taking the derivative of
% such a signal. We can use Savitsky-Golay to take the
% derivative of the smoothed signal. Here we will use the
% SAVGOL routine to  calculate the first derivative based
% on fitting a second order polynomial to 21 point windows.

y1 = savgol(y,21,2,1);

% Lets look at the plot now.

echo off
hold off, plot(scl,y1,'-b'); hold on 
text(5,.08,'First Derivative of Smoothed Signal')
plot([2 4],[.08 .08],'-b'), xlabel('Time in Seconds')
ylabel('Derivative of Signal')
title('Example of Savitsky-Golay Derivatives')
pause
echo on

% Once again, since we created the "true" signal, we have
% the opportunity to make some comparisons. The true signal
% was y = t*sin(t)/20, so the true derivative is 
% dy/dt = (sin(t) + t*cos(t))/20. The Savitsky-Golay routine
% assumes that the points are given at unit distances apart,
% and our sample was taken at increments of 0.1, so the
% calculated derivative must be divided by 10 to match the
% Savitsky-Golay estimate. We can compare this to
% our calculated derivative.

echo off
dy = (sin(scl) + scl.*cos(scl))/200;
plot(scl,dy,'-r'); text(5,0.06,'True Derivative')
plot([2 4],[0.06 0.06],'-r')
hold off
pause
echo on
  
% So we see that the calculated derivative is reasonably
% close to the true derviative. We can compare this to what
% we would have obtained by taking the first difference
% of the data.

echo off
plot(scl,y1,'-b',scl,dy,'-r',scl,[0 diff(y)],'-g')
hold on, plot([2 4],[.5 .5],'-b')
text(5,.5,'First Derivative of Smoothed Signal')
plot([2 4],[.4 .4],'-r'), text(5,.4,'True Derivative')
plot([2 4],[.3 .3],'-g'), text(5,.3,'First Difference')
xlabel('Time in Seconds')
ylabel('Derivative of Signal')
title('Example of Savitsky-Golay Derivatives'), hold off
pause
echo on

% As you can see, the Savitsky-Golay estimate is much better
% than the first difference estimate.

% The SAVGOL routine can also be used with matrices. It 
% assumes that each row is a series. As an example, we
% can use the NIR data shown here. (In order to save time
% we'll use only the first 5 samples.)

echo off
load nir_data
plot(lamda,spec1(1:5,:)), title('NIR Spectra')
ylabel('Absorbance'), xlabel('Wavelength')
pause
echo on

% We can now calculate the second derivative of the smoothed
% NIR spectra. We'll use a 7 point window and a cubic 
% polynomial for the estimate and plot it up.

dspec = savgol(spec1(1:5,:),7,3,2);

echo off
plot(lamda,dspec), title('Second Derivative of NIR Spectra')
xlabel('Wavelength'), ylabel('Absorbance Second Derivative')
pause
echo on

% As you can see, it is hard to tell the difference between
% the second derivative spectra. We can make the differences
% more apparent by mean centering using MNCN.

mdspec = mncn(dspec); 

echo off 
plot(lamda,mdspec)
title('Second Derivative Difference of NIR Spectra')
xlabel('Wavelength'), 
ylabel('Absorbance Second Derivative Difference')
echo on

% This "second derivative difference" spectra is often used
% in cases where there is a problem of baseline drift.
