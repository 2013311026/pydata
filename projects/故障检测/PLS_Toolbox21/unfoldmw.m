function mwauf = unfoldmw(mwa,order)
%UNFOLDMW Unfolds multiway arrays along specified order
%  The inputs are the multiway array to be unfolded (mwa),
%  and the dimension number along which to perform the
%  unfolding (order). The output is the unfolded array (mwauf).
%  This function is used in the development of PARAFAC models
%  in the alternating least squares steps.
%
%I/O: mwauf = unfoldmw(mwa,order);
%
%See also: MPCA, OUTER, OUTERM, PARAFAC, TLD

%Copyright Eigenvector Research, Inc. 1998
%bmw

mwasize = size(mwa);
ms = mwasize(order);
po = prod(mwasize);
ns = po/ms;
if order ~= 1
  pod = prod(mwasize(1:order-1));
end
mwauf = zeros(ms,ns);
for i = 1:ms
  if order == 1
    mwauf(i,:) = mwa(i:ms:po);
  else
    inds = zeros(1,ns); k = 1; fi = (i-1)*pod + 1;
	for j = 1:ns/pod
	  inds(k:k+pod-1) = fi:fi+pod-1;
	  fi = fi + ms*pod;
	  k = k + pod;
	end
	mwauf(i,:) = mwa(inds);
  end
end
