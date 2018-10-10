function [phi,gam,c,d] = fir2ss(b)
%FIR2SS Transform FIR model into equivalent state space model
%  The input is the vector of FIR coefficients (b). The
%  outputs are the phi, gamma, c and d matrices from
%  discrete state-space models.
%
%I/O: [phi,gamma,c,d] = fir2ss(b);
%
%See also: AUTOCOR, CROSSCOR, PLSPULSM, PULSDEMO, WRITEIN2, WRTPULSE

%Copyright Eigenvector Research 1991-98
%Modified BMW 11/93

[m,n] = size(b);
c = b;
phi = zeros(n);
phi(2:n,1:n-1) = eye(n-1);
gam = [1 zeros(1,n-1)]';
d = 0;
