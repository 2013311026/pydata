function [u2,y2] = writein2(u,y,n);
%WRITEIN2 Writes input and output matrices for dynamic model identificaton
%  This function writes files from process input and output vectors
%  that are the diagonal shifted type so that process models can
%  be obtained using PLS and other modelling methods. The
%  inputs are the original process input vector (u), the process
%  output vector (y), and the number of past inputs to consider (n).
%  The output of the function is the matrix of input sequences
%  (u2) and corresponding output vector (y2).
%
%  Note: for multiple input systems or systems with delays,
%  please see WRTPULSE.
%
%I/O: [u2,y2] = writein2(u,y,n);
%
%See also: AUTOCOR, CROSSCOR, FIR2SS PLSPULSM, PULSDEMO, WRTPULSE
 
%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 2/94

[m,n2] = size(u);
newm = m-n+1;
u2 = zeros(newm,n);
for i = 1:n
  u2(:,i) = u(n-i+1:m-i+1,:);
end
y2 = y(n:m,:);
