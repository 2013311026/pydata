function grad=gradnet1(t,u,kin,beta)
%GRADNET1 Calculates Jacobian of inner network....
%  This routine calculates the Jacobian of the inner network with
%  respect to the network weights. This routine is used in conjunction
%  with the leastsq.m routine in Optimization Toolbox.
%
%I/O: grad = gradnet1(t,u,kin,beta);

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95
	Lambda=.0002;
	Lam=sqrt(Lambda/2);
% Lambda=penalty used for large weights
	n=length(beta)-1;
	[m1,m2]=size(t);
	T=[ones(m1,1),t];
	Z=T*kin;
	[upred,usig]=bckprpnn(t,kin,beta);
	sigd=[2.*exp(-Z)./(1+exp(-Z)).^2];
% sigd equals derivative sigma with respect to Z
	bp=beta(2:n+1,1);
% bp = beta less bias. bp's multiply sigmas.
	sigt=sigd'*diag(t);
	sigd=sigd*diag(bp);
	sigt=(sigt'*diag(bp));
% Calculate Jaqcobian of objective function
	grad=zeros(m1+3*n+1,3*n+1);
	grad(1:m1,:)=[-usig,-sigd,-sigt];
	grad(m1+1:m1+3*n+1,1:3*n+1)=Lam*eye(3*n+1);
	grad=grad';
