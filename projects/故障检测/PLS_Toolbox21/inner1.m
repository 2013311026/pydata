function [x,f0]=inner1(n,b,t,u,plots)
%INNER1 Fits one dimensional nonlinear inner relationsip to score data
%  Routine to fit a one dimensional nonlinear inner relationship to score data.  
%  Inputs are the number of sigmoids (n), PLS regression vector (b),
%  X and Y-block scores vectors (t) and (u). Optional input (plots)
%  suppresses plotting when set to 0 {default = 1}.
%  If the user has the Optimization Toolbox LSQNONLIN is used otherwise
%  a supplied conjugate gradient optimization subroutine is used.
%  This routine is used after model structure has been determined and is
%  called by NPLSBLD1. Outputs are (x) the vector x of optimized weights,
%  and (f0) is the optimized function value.
%
%I/O: [x,f0]=inner1(n,b,t,u,weights,plots)
%
%See also: NNPLS, NPLSBLD1, INNER

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95
%nbg 11/00  remove global call, use of leastsq, and removed input "weights"
%           and changed the help

if nargin<5
  plots = 1;
end

%  Lambda is a parameter to penalize large weights
Lambda=0.0002;

% The statements below are executed if the Optimization Toolbox routine
% leastsq.m is found on the search path
 %if exist('leastsq')==2   %nbg 11/00
if exist('lsqnonlin')==2   %nbg 11/00
  Tscores=t;
  Uscores=u;
  optionss = optimset('lsqnonlin');   %nbg 11/00
elseif exist('leastsq')==2   %nbg 11/00
  Tscores=t;
  Uscores=u;
  optionss = optimset('lsqnonlin');   %nbg 11/00
end

% Initialize weights
% Every time the algorithm is used, the random seed is reset.  If one
% wants to try different starting points, the statement below can
% be deleted.
	randn('seed',0);
	beta=0.1*randn(n+1,1);
	beta(2,1)=1.;
	kin=0.1*randn(2,n);
	kin(2,1)=b*2.;
	kin(1,1)=-2*beta(1,1);
% Want first product of beta * kin = b. Others are small random #'s
	x0=[beta(:,1);(kin(1,:))';(kin(2,:))'];
% x0 is initial guess for weights

% If the user has the optimization toolbox then the following statements
% are used in place of conjugate gradient routine supplied.
% The options set parameters for Optimization Toolbox. See Optimization
% Toolbox manual. To use leastsq Tscores=t,  and Uscores = u have to be
% added as global variables to inner.m (see grad1.m)
%if exist('leastsq') == 2     %nbg 11/00
if exist('lsqnonlin')==2      %nbg 11/00
  optionss = optimset(optionss,'TolFun',0.001,'TolX',0.001, ...
    'LineSearchType','cubicpoly','MaxIter',50,'Display','off', ...
    'Jacobian','on');   %nbg 11/00
   x = lsqnonlin('fun1',x0,[],[],optionss,Tscores,Uscores);
elseif exist('leastsq')==2      %nbg 11/00
  options(2) = 0.001;
  options(3) = 0.001;
  options(7) = 1;
  options(14)= 50;
  x=leastsq('fun1',x0,options,'grad1');
else
  % cgrdsrch calls a conjugate gradient routine which returns optimized 
  % values for weights
  x=cgrdsrch(beta,kin,t,u);
end
beta=x(1:n+1);
kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
[upred,usig]=bckprpnn(t,kin,beta);
f0=(norm(u-upred))^2+Lambda*(norm(x))^2;
% check for plotting
if plots==1;
  z = get(gca,'Children');
  if get(z(1),'type') ~= 'text'
    set(z(1),'Visible','off')
  end
  [qq,i]=sort(t);
  for j=1:size(t);
    qqq(j)=upred(i(j));
  end
  plot(qq,qqq,'-r');
  pause
end
