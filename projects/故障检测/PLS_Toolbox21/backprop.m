function [upred,usig]=backprop(t,kin,beta);

% function to calculate backpropagation network output
% kin are the input weights and beta are the output weights on sigmoids.
% The first element of beta is bias on the output.
%  Copyright
%  Thomas Mc Avoy
%  1994
	[m1,m2]=size(t);
	T=[ones(m1,1),t];
	Z=T*kin;
	sig=[(1-exp(-Z))./(1+exp(-Z))];
	usig=[ones(size(t)),sig];
% usig equals the output of sigmoids plus a bias
	upred=usig*beta;
% upred is the predicted u output
