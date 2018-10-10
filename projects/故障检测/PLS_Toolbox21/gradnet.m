function grad=gradnet(t,u,beta,kin,Lambda)
%GRADNET Gradient of inner network with respect to network weights
%  This routine returns the gradient of the inner network with
%  respect to the network weights.
%
%I/O: grad=gradnet(t,u,beta,kin,Lambda);

%Copyright Thomas Mc Avoy 1994
%  Distributed by Eigenvector Research, Inc.
%  Modified by BMW 5-8-95
	n=length(beta)-1;
	m1=length(t);
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
% Calculate Jacobian of objective function
	jac=zeros(m1+3*n+1,3*n+1);
	jac(1:m1,:)=[-usig,-sigd,-sigt];
	jac(m1+1:m1+3*n+1,1:3*n+1)=Lambda*eye(3*n+1);
	jac=jac';
	grad=2.*jac*[(u-upred);beta;kin(1,:)';kin(2,:)'];
