function [upred,usig]=bckprpnn(t,kin,beta);
%BCKPRPNN Calculates backpropagation network output for NNPLS
%  Inputs are the input to the network (t), the input weights (kin)
%  and the output weights and biases on the sigmoids (beta). Note that
%  the first element of (beta) is the bias on the output. The outputs
%  are the predictions from the model, upred, and outputs of the sigmoids
%  plus the bias (usig).
%
%I/O: [upred,usig] = bckprpnn(t,kin,beta);
%
%See also: NNPLS

%  Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW 5-8-95
[m1,m2]=size(t);
T=[ones(m1,1),t];
Z=T*kin;
sig=[(1-exp(-Z))./(1+exp(-Z))];
[mt,nt] = size(t);
usig=[ones(mt,1),sig];
% usig equals the output of sigmoids plus a bias
upred=usig*beta;
% upred is the predicted u output
