function ypred = splspred(newx,P,W,C,cfs,ks,lvs,plots)
%SPLSPRED Predictions based on existing SPL_PLS model
%  This function is used to make predictions based on an existing
%  spline-pls model as identified by the spl_pls function.  
%  Inputs are the matrix of new independent variables (xnew), the
%  x-block loadings (P), x-block weights (W), inner coefficients
%  (C), spline coeficients (cfs), knot locations (ks), the number
%  of latent variables to consider (lvs) and the optional variable
%  (plots) which supresses all plots when set to 0.  The output is
%  the predicted values of the new samples (ypred).
%
%I/O: ypred = splspred(newx,P,W,C,cfs,ks,lvs,plots);

%See also: LWRXY, NNPLS, POLYPLS, PLS, SPL_PLS

%Copyright Eigenvector Research, Inc. 1992-98
%Modified BMW 4/94

if nargin == 7
  plots = 1;
end
[mx,nx] = size(newx);
[mC,nC] = size(C);
yvars = mC/nC;
ypred = zeros(mx,yvars);
U = zeros(mx,lvs);
[mcfs,ncfs] = size(cfs);
[mks,nks] = size(ks);
deg = mcfs-1;
knots = mks;
E = newx;
for i = 1:lvs
  t = E*W(:,i);
  U(:,i) = splnpred(t,cfs(1:mcfs,(mks+1)*(i-1)+1:(mks+1)*i),ks(:,i),0);
  if plots == 1
    plot(U(:,1:i)*C(yvars*(i-1)+1:yvars*i,1:i)')
    s = sprintf('Predicted dependent variables based on %g LVs',i);
    title(s)
	drawnow
  end
  E = E - t*P(:,i)';
end
ypred = U*C(yvars*(lvs-1)+1:yvars*lvs,1:lvs)';
  
