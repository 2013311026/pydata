function desgn = ffacdes1(k,p)
%FFACDES1 2^(k-p) fractional factorial design of experiments.
%  Input (k) is the total number of factors in the design, and
%  (p) is the number of confounded factors (default = 1);
%  p < k. (desgn) is a matrix of the experimental design.
%
%I/O: desgn = ffacdes1(k,p);
%
%See also: FACTDES

%Copyright Eigenvector Research, Inc. 1996-2000
%nbg

if nargin<2
  p    = 1;
end
if (p<0 | k<0)
  error('Error - inputs must be > 0')
end
if (p>(k+1)/2)
  error('Error - only designs with k-p+1>=p allowed')
end
if p >= k
  error('Error - p must be less than k')
end

desgn  = factdes(k-p);
nexp   = size(desgn,1);

if p ~= 0
  if p == 1
    %confound with all k-p
	  y    = mncn(desgn)*2;
	  conf = y(:,1);
	  for ii = 2:k-p
      conf = conf.*y(:,ii);
	  end
	  conf = scale(conf,-1)/2;
	  desgn = [desgn,conf];
  else
    %confound with k-p-1
	  [z,ii]= sort(sum(desgn')');
	  jj    = find(z==k-p-1);
	  z     = desgn(ii,:);
	  ii    = jj(1);
	  for jj = 1:p
	    kk  = find(z(ii,:));
      y   = mncn(desgn(:,kk))*2;
	    conf= y(:,1);
	    for ij = 2:length(kk)
	      conf = conf.*y(:,ij);
	    end
	    conf  = scale(conf,-1)/2;
	    desgn = [desgn,conf];
	    ii    = ii + 1;
	  end  
  end
end


