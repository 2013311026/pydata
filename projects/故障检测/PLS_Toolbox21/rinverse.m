function rinv = rinverse(p,t,w,f);
%RINVERSE Calculates pseudo inverse for PLS, PCR and RR models
%  Inverse calculated depends upon the number of inputs supplied.
%  For PLS models, the inputs are the loadings (p),
%  scores (t), weights (w) and number of LVs (lvs).
%
%I/O:  rinv = rinverse(p,t,w,lvs);
%
%  For PCR models, the inputs are the loadings (p),
%  scores (t), and number of PCs (pcs).
%
%I/O:  rinv = rinverse(p,t,pcs);
%
%  For ridge regression (RR) models, the inputs are
%  the scaled x matrix (sx) and ridge parameter (theta).
%
%I/O:  rinv = rinverse(sx,theta).
%  
%See also: PLS, PCR, RIDGE, STDSSLCT

%Copyright Eigenvector Research, Inc. 1996-98
%bmw

[m,n] = size(p);
if nargin == 4
  if f > n
    error('Number of LVs requested exceeds number given')
  end
  % The PLS pseudo inverse is defined by
  rinv = w(:,1:f)*inv(p(:,1:f)'*w(:,1:f))*inv(t(:,1:f)'*t(:,1:f))*t(:,1:f)';
elseif nargin == 3
  if w > n
    error('Number of PCs requested exceeds number given')
  end
  % The PCR pseudo inverse is definedy by 
  rinv = p(:,1:w)*inv(t(:,1:w)'*t(:,1:w))*t(:,1:w)';
elseif nargin == 2
  ridi = diag(diag(p'*p));
  % The RR pseudo inverse is defined by
  rinv = inv(p'*p + ridi*t)*p';
else
  error('Number of input arguments must be 2 (RR), 3 (PCR) or 4 (PLS)')
end
