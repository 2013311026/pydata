function df=grad1(x)
%GRAD1 Calcualtes Jocobian of objective function for training NNPLS
%  Routine to calculate the Jacobian of fun1 for optimization with leastsq.
%  grad1 here is different from gradient that is used with conjugate 
%  gradient routine cgrdsrch.
%  See Optimization Toolbox.
%
%I/O: df = grad1(x);

%Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW  5-8-95
global Tscores Uscores
% these global variable need to be added to inner.m
	t=Tscores;
	u=Uscores;
	n=(length(x)-1)/3;
	beta=x(1:n+1);
	kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
% gradnet1 calculates the Jacobian
	df=gradnet1(t,u,kin,beta);
