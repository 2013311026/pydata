function [sx,alpha,beta] = mscorr(x,xref,mc);
%MSCORR Multiplicative scatter correction (MSC)
%  MSCORR performs multiplicative scatter correction
%  (aka multiplicative signal correction) on an input
%  matrix of spectra (x) regressed against a reference
%  spectra (xref).  If the optional input (mc) is 
%  1 {default} each spectra is mean centered, if (mc) 
%  is set to 0 no mean centering is performed.
%  The outputs are the corrected spectra (sx), the 
%  intercepts/offsets (alpha) and the multiplicative 
%  scatter factor/slope (beta).
%
%I/O: [sx,alpha,beta] = mscorr(x,xref,mc);
%
%See also: STDFIR, STDGEN, STDGENNS, STDGENDW

%Copyright Eigenvector Research, Inc. 1997-99
%nbg 3/99

[m,n]       = size(xref);
if m>1&n>1, error('Input xref must be a vector'), end
if n>m
  xref      = xref'; %make xref a column vector
  m         = n;
end
if m~=size(x,2)
  error('Input xref length not compatible with x')
end
if nargin<3, mc = 1; end
if mc==0
  alpha       = zeros(size(x,1),1);
  beta        = (xref\x')';
  sx          = x./beta(:,ones(1,size(x,2)));
else
  [sx,alpha]  = mncn(x');
  [xref,mx]   = mncn(xref);
  beta        = (xref\sx)';
  alpha       = (alpha-mx*beta')';
  sx          = (x-alpha(:,ones(m,1)))./beta(:,ones(1,m));
end
