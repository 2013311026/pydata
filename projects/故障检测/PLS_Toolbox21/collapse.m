function [W12,W23,B2,B3]=collapse(NEURAL,W,Q,P,fac)
%COLLAPSE Calculates final neural net model from NNPLS
%  The inputs are parameters in the neural network inner model, (NEURAL),
%  the PLS X-block weights (W), Y-block weights (Q), X-block loadings
%  (P) and the number of factors to be used (fac). The outputs are the
%  weights to the hidden nodes (W12), weights to the output nodes (W23),
%  biases on the hidden nodes (B2) and biases on the output nodes (B3).
%
%I/O: [W12,W23,B2,B3]=collapse(NEURAL,W,Q,P,fac);
%
%See also NNPLS, NNPLSPRD

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW on 5-8-95
%Modified by DAS 10-25-95
f=0;
% Need to have as many copies of weights as there are sigmoids
temp=eye(size(W(:,1)*W(:,1)'));
% temp is used since NNPLS is developed with residuals
for i=1:fac
  for j=1:NEURAL(1,i);
  % NEURAL(1,i) gives the number of sigmoids used
    W12(f+j,:)=NEURAL(2*NEURAL(1,i)+2+j,i)*W(:,i)'*temp';
    B2(f+j)=NEURAL(NEURAL(1,i)+2+j,i);
  end
  f=f+NEURAL(1,i);
  % The next 7 lines of code were added by DAS to avoid formation 
  % of large matrices
  s1=size(W(:,i)*W(:,i)');
  m1=eye(s1);
  m2=W(:,i)*P(:,i)';
  m3=m1-m2;
  clear m1 m2;
  temp=temp*m3;
  clear m3
end
% Hidden to Output Node Weights are W23
f=0;
B3=zeros(size(Q(:,1)'));
% Need to have as many copies of weights as there are sigmoids
for i=1:fac
  for j=1:NEURAL(1,i);
    W23(j+f,:)=NEURAL(2+j,i)*Q(:,i)';
  end
  B3=B3+NEURAL(2,i)*Q(:,i)';
  f=f+NEURAL(1,i);
end


		
	
