function [f,df] =fun1(x,Tscores,Uscores)
%FUN1 Objective function calculation for NNPLS
%  Function calculation for use with optimization routine
%  for determining weights in backprop network.
%
%I/O: f = fun1(x,Tscores,Uscores);

%Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW 5-8-95
%nbg 11/00 removed global call, added grad1 = grad1 as subroutine

if (exist('lsqnonlin')~=2)&(exist('leastsq'))
  global Tscores Uscores      %nbg 11/00
  lsqflag = 1;
else
  lsqflag = 0;
end
% Lambda=penalty used for large weights
	t=Tscores;
	u=Uscores;
	n=(length(x)-1)/3;
	Lambda=.0002;
	Lam=sqrt(Lambda/2);
	beta=x(1:n+1);
	kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
	[upred,usig]=bckprpnn(t,kin,beta);
%	f=norm(u-upred)^2+Lambda*norm(x)^2;
	f=[(u-upred);Lam*x];
  if lsqflag==1
    df = grad1(x);
  else
    df = grad2(x,Tscores,Uscores)';  %nbg 11/00
  end

%added grad2 = grad1 nbg 11/00
function df=grad2(x,Tscores,Uscores)
%GRAD2 Calcualtes Jocobian of objective function for training NNPLS
%  Routine to calculate the Jacobian of fun1 for optimization with leastsq.
%  grad1 here is different from gradient that is used with conjugate 
%  gradient routine cgrdsrch.
%  See Optimization Toolbox.
%
%I/O: df = grad2(x)

%Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW  5-8-95
%global Tscores Uscores    nbg 11/00

% these global variable need to be added to inner.m
	t=Tscores;
	u=Uscores;
	n=(length(x)-1)/3;
	beta=x(1:n+1);
	kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
% gradnet1 calculates the Jacobian
	df=gradnet1(t,u,kin,beta);