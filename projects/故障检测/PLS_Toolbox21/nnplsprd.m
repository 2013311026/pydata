function ynpred=nnplsprd(W12,W23,B2,B3,x)
%NNPLSPRD Predictions using collapsed NNPLS model
%  This program uses the collapsed NNPLS model to predict the responses
%  of a new x block. The inputs are the the input to hidden layer weights 
%  (W12), hidden layer to output weigts (W23), hidden layer biases (B2), 
%  output bias (B3) and new x-block (x). The output is the new y-block
%  predictions (ynpred).
%
%I/O: ynpred = nnplsprd(W12,W23,B2,B3,x)

[nx,mx]=size(x);
for i=1:nx
	yt(i,:)=(x(i,:)*W12'+B2);
end;
yt=[(1-exp(-yt))./(1+exp(-yt))];
for i=1:nx
	ynpred(i,:)=(yt(i,:)*W23+B3);
end;



