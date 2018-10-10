function [W,Q,P,NEURAL,ssqdif,press] = nnpls(x,y,xtest,ytest,fac,opts)
%NNPLS Partial Least Squares with Neural Net inner relationship
%  Inputs are the predictor variable block (x), the predicted
%  variable block (y), the predictor test data block for cross
%  validation (xtest), the predicted test data block (ytest), the
%  number of factors or latent variables to calculate (fac), and a
%  vector of options (opts) which can be used to change the default
%  settings for several parameters (see below). Outputs are the
%  matrix of PLS x-block weight vectors (W), y-block loadings (Q),
%  x-block loadings (P), inner relationship neural network model
%  parameters (NEURAL), the sum of squares captured information
%  (ssqdif), and the prediction error sum of squares as a function
%  of number of factors (press).
%
%I/O: [W,Q,P,NEURAL,ssqdif,press] = nnpls(x,y,xtest,ytest,fac,opts);
%
%  If used, the optional input (opts) must be a 3 element vector.
%  Set opts(1) = 1 to plot the inner relationship as the function proceeds
%  {default = 0, no plots}.
%  Set opts(2) to change the maximum number of sigmoids for each
%  latent variables from the default of six. If opts(2) = 0, the
%  default of 6 will be used.
%  Set opts(3) to change the tolerance on the change in press when
%  determining number of sigmoids to use in each factor. This is normally
%  set to 0.01 (1%).
%
%  To make predictions with the NNPLS model, use the functions 
%  COLLAPSE and NNPLSPRD. For a demo see NNPLSDMO.
%
%  Note: The first row in NEURAL is the number of sigmoids in that factor. 
%  The default value is a maximum of 6. The next entries are the output weights, 
%  the input biases, and input weights. COLLAPSE is used to calculate the 
%  weights in a standard backpropagation neural net from NEURAL. 

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified BMW 5/9/95
%nbg 11/00 trade leastsq for lsqnonlin

if nargin < 6
  opts   = [0 6 0.01];
  plots  = 0;
  maxsig = 6;
  tol    = 0.01;
else 
  plots = opts(1);
  if plots~=1
    plots = 0; 
  end
  if length(opts)>1
    maxsig = opts(2);
    if maxsig <= 0, 
	    maxsig  = 6;
      opts(2) = maxsig;
    end
  else
    maxsig    = 6;
    opts(2)   = maxsig;
  end
  if length(opts) > 2
    if (opts(3)<=0)|(opts(3)>1)
      disp('opts(3) must be >0 & <1, resetting to 0.01.')
      tol     = 0.01;
      opts(3) = tol;
    else
      tol     = opts(3);
    end
  else
    tol       = 0.01;
    opts(3)   = tol;
  end
end
disp(' ')
disp(sprintf('A maximum of %g sigmoids will be used in each factor.',opts(2)));
disp(sprintf('A tolerance of %g percent will be used on PRESS minimum.',tol*100));
disp(' ')
%if exist('leastsq') == 2
if exist('lsqnonlin')==2
  disp('LSQNONLIN from Optimization Toolbox R12 2.1 found on search path.')  %nbg 11/00
  disp('Using LSQNONLIN for fitting inner relationships.')           %nbg 11/00
elseif exist('leastsq')==2
  disp('LEASTSQ from Optimization Toolbox found on search path.')  %nbg 11/00
  disp('Using LEASTSQ for fitting inner relationships.')           %nbg 11/00
else
 %  disp('LEASTSQ from Optimization Toolbox not found on search path.')
  disp('LSQNONLIN from Optimization Toolbox not found on search path.')
  disp('Using optimization techniques supplied with PLS_Toolbox')
end
disp('  ');
if plots == 1
  disp('Plots option is turned on so routine will pause after each sigmoid')
  disp('is added in each factor. Hit return to continue')
else
  disp('Plot option turned off')
end 
disp('  ')
[mx,nx] = size(x);
[my,ny] = size(y);
if nx < fac
  error('No. of LVs must be <= no. of x-block variables')
end 
Q = zeros(ny,fac);
W = zeros(nx,fac);
NEURAL=zeros(2+3*maxsig,fac);
ssq = zeros(fac,2);
ssqx = 0;
for i = 1:nx
  ssqx = ssqx + sum(x(:,i).^2);
end
ssqy = sum(sum(y.^2)');
yhtest=zeros(size(ytest));
ysav=ytest;
for i = 1:fac
	[p,q,w,t,u] = plsnipal(x,y);
 	ttest=xtest*w;
  utest=ytest*q;
 	[n,weights,upred]=nnpls1(t,u,ttest,utest,i,opts);
% Calculate residuals by subtracting model
  x = x - t*p';
  y = y - upred*q';
	beta=weights(1:n+1);
	kin=[weights(n+2:2*n+1)';weights(2*n+2:3*n+1)'];
	[uupred,uusig]=bckprpnn(ttest,kin,beta);
	xtest=xtest-ttest*p';
	ytest=ytest-uupred*q';
% Calculate predicted test set outputs
	yhtest=yhtest+uupred*q';
% Calculate the press for i factors
	press(i)=norm(ysav-yhtest)^2;
	z=press(i);
	disp('  Factor #     PRESS')
	format = '    %2.0f       %5.2e';
	tab = sprintf(format,[i,press(i)]); disp(tab)
  	NEURAL(1,i)=n;
  	NEURAL(2:2+3*maxsig,i)=weights;
  	ssq(i,1) = (sum(sum(x.^2)'))*100/ssqx;
  	ssq(i,2) = (sum(sum(y.^2)'))*100/ssqy;
  	W(:,i) = w(:,1);
  	Q(:,i) = q(:,1);
	P(:,i)=p(:,1);
end;
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
if (exist('lsqnonlin')~=2)&(exist('leastsq')==2)
  clear global Tscores Uscores
end

