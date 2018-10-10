function [newu,newy] = wrtpulse(u,y,n,delay);
%WRTPULSE Creates input/output matrices for dynamic model identification
%  This function rewrites vectors of system inputs and output
%  so that they may be used with the PLS and other modelling
%  routines to obtain finite impulse response and ARX models.
%  The inputs are the input vector or matrix of input vectors (u),
%  (where the each input is a column vector), the process output
%  vector (y), a scalar or vector of number of past periods to
%  consider for each input (n), and a scalar or vector of delays 
%  corresponding to each input (delay). The output of the 
%  function is a matrix of lagged input variables (newu) and 
%  corresponding output vector (newy).
%
%I/O: [newu,newy] = wrtpulse(u,y,n,delay);
%
%See also: AUTOCOR, CROSSCOR, FIR2SS, PLSPULSM, PULSDEMO, WRITEIN2

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 2/94

[mu,nu] = size(u);
[my,ny] = size(y);
%  Check to see that matrices are of consistant dimensions
if nu > mu
  error('the input u is supposed to be colmn vectors')
end
if ny ~= 1
  error('the output y is supposed to be a colmn vector')
end
if mu ~= my
  error('There must be an equal number of points in the input and output vectors')
end
%  Find maximum number of terms for all inputs
a = max(n+delay);
%  Write out file using maximum number of terms
for i = 1:nu 
  [temp,newy] = writein2(u(:,i),y,a);
%   Delete proper number of columns according to delay and # of coeffs
  temp = temp(:,delay(:,i)+1:n(:,i)+delay(:,i));
%  Construct total matrix from each input part
  if i == 1
    newu = temp;
  else
    newu = [newu temp];
  end
end
