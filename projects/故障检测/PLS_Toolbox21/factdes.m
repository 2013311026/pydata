function desgn = factdes(fact,levl)
%FACTDES full factorial design of experiments.
%  Input (fact) is the number of factors in the design,
%  (levl) is the number of levels (default = 2). (desgn)
%  is the matrix of the experimental design. If levl=2
%  and fact=k then this gives a 2^k design. To obtain
%  a center point of zero (column means zeros) use
%  desgn = mncn(desgn);
%
%I/O: desgn = factdes(fact);
%  provides a full factorial two level design, and
%
%I/O: desgn = factdes(fact,levl);
%  provides a full factorial levl level design.
%
%See also: FFACDES1

%Copyright Eigenvector Research, Inc. 1996-98
%nbg

if nargin<2
  levl = 2;
end

nexp   = levl^fact;

desgn  = zeros(nexp,fact);
for ii = 1:nexp-1
  mexp   = ii;
  jj     = fact;
  while mexp > 0
    mnx  = mexp/levl;
	trn  = floor(mnx);
    desgn(ii+1,jj) = round((mnx-trn)*levl);
	mexp = trn;
	jj   = jj - 1;
  end 
end
