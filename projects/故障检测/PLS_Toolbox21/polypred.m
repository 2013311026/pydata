function ypred = polypred(x,b,p,q,w,lv)
%POLYPRED Prediction with POLYPLS models
%  The inputs are the matrix of predictor variables (x),
%  the POLYPLS model inner-relation coefficients (b),
%  the x-block loadings (p), the y-block loadings (q),
%  the x-block weights (w), and number of latent
%  variables to use for prediction (lv).
%
%I/O: ypred = polypred(x,b,p,q,w,lv);
%
%See also: LWRXY, NNPLS, POLYPLS, PLS, SPL_PLS

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 11/93
%Checked on MATLAB 5 by BMW

[mx,nx] = size(x);
[mq,nq] = size(q);
[mw,nw] = size(w);
that = zeros(mx,lv);
ypred = zeros(mx,mq);
if lv > nw
  s = sprintf('Maximum number of latent variables exceeded (Max = %g)',nw);
  error(s)
end
%  Start by calculating all the xblock scores
for i = 1:lv
  that(:,i) = x*w(:,i);
  x = x - that(:,i)*p(:,i)';
end
%  Use the xblock scores and the b to build up the prediction
for i = 1:lv
ypred = ypred + (polyval(b(:,i),that(:,i)))*q(:,i)';
end
