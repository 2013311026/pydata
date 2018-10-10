function [nas,nnas,sens,sel,nfnas] = figmerit(x,y,Rhat)
%FIGMERIT Analytical figures of merit for multivariate calibration
%  Calculates analytical figures of merit for PLS and PCR models.
%  The inputs are the preprocessed (usually centered and scaled)
%  spectral data (x), the preprocessed analyte data (y), and the
%  PCR or PLS approximation to x, (Rhat). Generally, Rhat is found
%  by multiplying the scores by the loadings from PLS or PCR, using
%  the number of LVs or PCs in the corresponding calibration model.
%  The outputs are the matrix of net analyte signals for each of the
%  spectra (nas), the norm of the net analyte signal for each sample
%  (nnas), the matrix of sensitivities for each sample (sens), the
%  vector of selectivities for each sample (sel), and the "noise
%  filtered" estimate of the net analyte signal (nfnas), which is
%  just the multiple of the regression vector that best fits the nas.
% 
%Example: given the 7 LV PLS model formed from
%  [b,ssq,p,q,w,t,u,bin] = pls(x,y,7);
%  Rhat = t*p';
%
%I/O: [nas,nnas,sens,sel,nfnas] = figmerit(x,y,Rhat);

%Copyright Eigenvector Research, Inc. 1997-98
%Barry M. Wise May 30, 1997
 
[mx,nx] = size(x);
nas = zeros(mx,nx);
nnas = zeros(mx,1);
sel = zeros(mx,1);
rhat = mean(Rhat(find(y>0),:));
[u,s,v] = svd(Rhat,0);
npcs = max(find((diag(s)/s(1,1)) > 1e-10));
Rhatinv = (u(:,1:npcs)*inv(s(1:npcs,1:npcs))*v(:,1:npcs)')';
chatk = Rhat*Rhatinv*y;
alpha = inv(rhat*Rhatinv*chatk);
Rhat_k = Rhat - alpha*chatk*rhat;
[u,s,v] = svd(Rhat_k);
Rhat_kinv = (u(:,1:npcs-1)*inv(s(1:npcs-1,1:npcs-1))*v(:,1:npcs-1)');
temp = Rhat_kinv'*Rhat_k;
temp = x*temp;
nas = x - temp;
if nargout > 4
  nfnas = Rhat - temp;
end
sens = nas;
for i = 1:mx
  nnas(i) = norm(nas(i,:));
  sel(i) = nnas(i)/norm(x(i,:));
  sens(i,:) = sens(i,:)/y(i);
end


