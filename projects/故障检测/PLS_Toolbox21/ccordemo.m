%CCORDEMO Demonstrates the autocor and crosscor functions

%Copyright Eigenvector Research, Inc. 1997-98
%Modified 1/97 NBG
%Checked 3/98 BMW

echo on
% First lets create some input/output data from a process.  Imagine that
% we are trying to determine the lag time of vibrations through a
% structure.  We'll use a random signal vibrational input u at one
% point in the structure and we'll listen somewhere else for the
% output y.  We can create the input signal u easily, and then we'll
% look at its autocorrelation function.
pause

echo off
randn('seed',.12);
u = randn(1000,1);
plot(u)
title('Random signal u versus time')
xlabel('Time')
pause

echo on

% Now we'll use the autocor function to get the autocorrelation
% spectrum of u.
pause

autocor(u,20);
pause

% As you can see, the signal u is completely uncorrelated in time.
% Imagine now that the output y is also very noisy, but that the
% input is delayed and adds to the noisy y.  First lets create y
% and look at its autocorrelation function.
pause

echo off
y = randn(size(u));
y(6:1000,1) = y(6:1000,1)+0.2*u(1:995,1);
plot(y)
title('Output signal y versus time')
xlabel('Time')
pause

echo on
% Now lets look at its autocorrelation spectrum
pause

acory = autocor(y,20);
pause

% As you can see, y is also completely uncorrelated.  Now lets see if it
% correlates with u by using the crosscorrelation function.
pause

ccoruy = crosscor(u,y,20);
pause

% As you can see, y has an echo of u in it at 5 units delay.
