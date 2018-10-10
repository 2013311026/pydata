function mwa = outerm(facts,lo,vect)
%OUTERM Outer product of any number of vectors with multiple factors
%  The input to outerm is a 1 by n cell array (facts), where each cell
%  contains the factors for one of the ways, or orders, with each
%  of the factors being a column in the matrix. Optional inputs
%  are the number of an order to leave out (lo) in the formation
%  of the product, and a flag (vect) which causes the function
%  to not sum and reshape the final factors when set to 1. (This option
%  is used in the alternating least squares steps in PARAFAC.) 
%  The output is the multiway array resulting from multiplying the
%  factors together(mwa), or the strung out individual factors.
%
%I/O: mwa = outerm(facts,lo,vect);
%
%See also: OUTER, PARAFAC, TLD

%Copyright Eigenvector Research, Inc. 1998
%bmw

if nargin < 2
  lo = 0;
end
if nargin < 3
  vect = 0;
end
order = length(facts);
if lo == 0
  mwasize = zeros(1,order);
else
  mwasize = zeros(1,order-1);
end
k = 0;
for i = 1:order
  [m,n] = size(facts{i});
  if i ~= lo
    k = k + 1;
    mwasize(k) = m;
  end
  if i > 1
    if nofac ~= n
	  error('All orders must have the same number of factors')
	end
  else
    nofac = n;
  end
end
mwa = zeros(prod(mwasize),nofac);

for j = 1:nofac
  if lo ~= 1
    mwvect = facts{1}(:,j);
    for i = 2:order
	  if lo ~= i
        %mwvect = kron(facts{i}(:,j),mwvect);
		mwvect = mwvect*facts{i}(:,j)';
		mwvect = mwvect(:);
	  end
    end
  elseif lo == 1
    mwvect = facts{2}(:,j);
	for i = 3:order
      %mwvect = kron(facts{i}(:,j),mwvect);
	  mwvect = mwvect*facts{i}(:,j)';
	  mwvect = mwvect(:);
	end
  end
  mwa(:,j) = mwvect;
end
% If vect isn't one, sum up the results of the factors and reshape
if vect ~= 1
  mwa = sum(mwa,2);
  mwa = reshape(mwa,mwasize);
end

