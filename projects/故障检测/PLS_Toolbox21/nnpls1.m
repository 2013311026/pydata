function [n,wts,upred]=nnpls1(t,u,ttest,utest,ii,opts)
%NNPLS1 Calculates a single NN-PLS factor
%  Routine to carry out NNPLS.  A conjugate gradient optimization
%  subroutine is supplied.  If the user has the Optimization Toolbox
%  leastsq.m can be used.  nnpls1.m calls inner.m, and it requires
%  t and u which are the training scores, and ttest and utest which are
%  the test scores and ii which is the current factor being calculated
%  Test set validation is used to determine the number of
%  sigmoids in the inner neural network that minimizes the PRESS.  
%
%  If used, the optional input (opts) must be a three element row vector.
%  Set opts(1) = 1 to plot the inner relationship as the function proceeds.
%  Set opts(2) to change the maximum number of sigmoids for each
%  latent variables from the default of six. If opts(2) = 0, the
%  default of 6 will be used.
%  Set opts(3) to change the tolerance on the change in press when
%  determining number of sigmoids to use in each factor. This is normally
%  set to 0.01 (1%).
%  
%  nnpls1.m returns the number of sigmoids, n, the network weights, wts
%  and the u scores predicted by the inner neural net, upred.
%
%I/O: [n,wts,upred] = nnpls1(t,u,ttest,utest,ii,opts);

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95

if nargin < 6
  plots = 0;
  sigmax = 6;
  tol = .01;
else 
  plots = opts(1);
  if plots ~= 1, plots = 0; end
  sigmax = opts(2);
  if sigmax <= 0, sigmax = 6; end
  tol = opts(3);
end
n=1;
% Calculate linear PLS coefficient to initialize neural net
b=u'*t/(t'*t);
% check for plotting
if plots==1
  clf
  plot(t,b*t)
  hold on
  s = sprintf('Inner Relationship For Factor %g',ii);
  title(s)
  s = sprintf('Score (t) on X-block Factor %g',ii);
  xlabel(s);
  s = sprintf('Score (u) on Y-block Factor %g',ii);
  ylabel(s); 
  plot(ttest,utest,'xg')
  plot(t,u,'ob')
  z = axis; 
  zx1 = z(1)+(z(2)-z(1))*.07;
  zy1 = z(3)+(z(4)-z(3))*.95;
  zx2 = z(1)+(z(2)-z(1))*.12;
  zy2 = z(3)+(z(4)-z(3))*.90;
  zx3a = z(1)+(z(2)-z(1))*.06;
  zx3b = z(1)+(z(2)-z(1))*.08;
  zy3 = z(3)+(z(4)-z(3))*.85;
  plot(zx1,zy1,'xg')
  plot(zx1,zy2,'ob')
  plot([zx3a zx3b],[zy3 zy3],'-r')
  text(zx2,zy1,'Testing Data')
  text(zx2,zy2,'Training Data')
  text(zx2,zy3,'Inner Relationship Fit')
  hold off
  pause
end
% Calculate inner model for 1 sigmoid using optimization
[weights,f0]=inner(n,b,t,u,[],plots);
% Calculate the press for 1 sigmoid
beta=weights(1:2);
kin=[weights(3)';weights(4)'];
[uupred,uusig]=bckprpnn(ttest,kin,beta);
press=norm(utest-uupred)^2;
% Calculate the press for n sigmoids
% if PRESS goes up terminate the calculation. Also terminate if change
% in objective function is less than 1% or specified tolerance
n=2;
check=ones(2,1);
while any(check)>0;
  savwts=weights;
  savpress=press;
  if n==2
    check(1,1)=0;
  end
  [weights,f1]=inner(n,b,t,u,weights,plots);
% check if objective function changes by less than 1 or specified tolerance
  if (abs((f1-f0)/f1))<tol; 
    check(2,1)=0;
    weights=savwts;
    n=n-1;
  else
	f0=f1;
  end
  beta=weights(1:n+1);
  kin=[weights(n+2:2*n+1)';weights(2*n+2:3*n+1)'];
  [uupred,uusig]=bckprpnn(ttest,kin,beta);
  press1=norm(utest-uupred)^2;
  if check(2,1)~=0;
    if (press1>press);
      check(2,1)=0;
      weights=savwts;
      n=n-1;
	else
      n=n+1;
      press=press1;
    end
  end
% check if 6 sigmoids have been used. If so terminate.
  if n==sigmax+1
    n=n-1;
    check(2,1)=0;
	s = sprintf('%g sigmoids have been used and min PRESS not obtained',sigmax);
    disp(s)
  end
end
wts=zeros(3*sigmax + 1,1);
wts(1:3*n+1,1)=weights(1:3*n+1);
[upred,usig]=bckprpnn(t,kin,beta);


	
	 
	

	


