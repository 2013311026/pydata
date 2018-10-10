function [W,Q,P,NEURAL,ssqdif] = nnplsbld(x,y,fac,nosig,plots)
%NNPLSBLD Calculates NNPLS model once structue has been determined
%  NNPLSBLD calculates an NNPLS model for given X and Y-blocks
%  (x) and (y), the number of PLS factors (fac), and the number
%  of sigmoids (nosig) for each factor. (nosig) is a vector with
%  (fac) elements giving the number of sigmoids for each factor.
%  NNPLSBLD can be used after the NNPLS model structure has been
%  determined with test set validation. Optional input (plots)
%  supresses plotting when set to zero {default = 1}.  
%  Outputs (W), (Q), and (P) are the PLS input and output parameter matrices.
%  Output (NEURAL) contains the weights of the inner neural networks.
%  The first row of (NEURAL) is the number of sigmoids in that factor.  
%  The next entries are the output weights, the input biases, and input 
%  weights. The routine COLLAPSE is used to calculate the weights
%  in a standard backpropagation neural net from (NEURAL). NNPLSBLD also 
%  outputs the fraction of variance captured in the (x) and (y) matrices.
%  
%I/O: [W,Q,P,NEURAL,ssqdif] = nnplsbld(x,y,fac,nosig,plots);
%
%See also: NNPLS

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95
%nbg 11/00 replaced leastsq for lsqnonlin, changed help

if nargin < 5
  plots = 0;
end
if plots ~= 1
  plots = 0;
end
disp('  ')
%if exist('leastsq') == 2   %11/00 nbg
if exist('leastsq') == 2
  disp('LSQNONLIN from Optimization Toolbox found on search path.')
  disp('Using LSQNONLIN for fitting inner relationships.')
%  disp('LEASTSQ from Optimization Toolbox found on search path.')
%  disp('Using LEASTSQ for fitting inner relationships.')
else
  disp('LSQNONLIN from Optimization Toolbox not found on search path.')
%  disp('LEASTSQ from Optimization Toolbox not found on search path.')
  disp('Using optimization techniques supplied with PLS_Toolbox')
end
disp('  ');
if plots == 1
  disp('Plots option is turned on so routine will pause after each sigmoid')
  disp('is added in each factor. Hit return to continue')
else
  disp('Plot option turned off')
end 
[mx,nx] = size(x);
[my,ny] = size(y);
if nx < fac
  error('No. of LVs must be <= no. of x-block variables')
end; 
Q = zeros(ny,fac);
W = zeros(nx,fac);
NEURAL=zeros(20,fac);
ssq = zeros(fac,2);
ssqx = 0;
for i = 1:nx
  ssqx = ssqx + sum(x(:,i).^2);
end
ssqy = sum(sum(y.^2)');
for i = 1:fac
	[p,q,w,t,u] = plsnipal(x,y);
 	[weights,upred]=nplsbld1(t,u,i,nosig(i),plots);
	n=nosig(i);
  % Calculate residuals by subtracting model
 	x = x - t*p';
 	y = y - upred*q';
	beta=weights(1:n+1);
	kin=[weights(n+2:2*n+1)';weights(2*n+2:3*n+1)'];
 	NEURAL(1,i)=n;
 	NEURAL(2:20,i)=weights;
 	ssq(i,1) = (sum(sum(x.^2)'))*100/ssqx;
 	ssq(i,2) = (sum(sum(y.^2)'))*100/ssqy;
 	W(:,i) = w(:,1);
  Q(:,i) = q(:,1);
	P(:,i)=p(:,1);
end
ssqdif = zeros(fac,2);
ssqdif(1,1) = 100 - ssq(1,1);
ssqdif(1,2) = 100 - ssq(1,2);
for i = 2:fac
  for j = 1:2
    ssqdif(i,j) = -ssq(i,j) + ssq(i-1,j);
  end
end
ssq = [(1:fac)' ssqdif(:,1) cumsum(ssqdif(:,1)) ssqdif(:,2) ...
  cumsum(ssqdif(:,2))];
disp('  ')
disp('       Percent Variance Captured by PLS Model   ')
disp('  ')
disp('           -----X-Block-----    -----Y-Block-----')
disp('   LV #    This LV    Total     This LV    Total ')
disp('   ----    -------   -------    -------   -------')
format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
for i = 1:fac
  tab = sprintf(format,ssq(i,:)); disp(tab)
end
disp('  ')
%if exist('leastsq') == 2
%  clear global Tscores Uscores
%end
hold off
