function mwarray = outer(varargin)
%OUTER Computes outer product of any number of vectors
%  The input is either 1 by n cell array where each cell
%  contains a vector, or a list of vectors. The output is
%  the multiway array resulting from taking the outer
%  product of each of the vectors.
%
%Example: mwa = outer(1:5,1:8,1:3) produces at 5x8x3
%  array of the outer product of the input vectors.
%  Similarly, x = {1:5,1:8,1:3}, mwa = outer(x) produces
%  the same result.
%
%I/O: mwa = outer(varargin);
%
%See also: OUTERM, PARAFAC, TLD, UNFOLDMW, VARARGIN

%Copyright Eigenvector Research, Inc. 1998
%bmw

% If there is only one input, assume it was a cell array
if nargin == 1
  varargin = varargin{1};
  order = length(varargin);
else  % assume it was a bunch o vectors
  order = nargin;
end
mwasize = zeros(1,order);
for i = 1:order
  mwasize(i) = length(varargin{i});
  d = size(varargin{i});
  if (min(d) > 1 | length(d) > 2)
    error('All inputs must be vectors')
  elseif d(2) > d(1)
    varargin{i} = varargin{i}';
  end
end
mwarray = zeros(mwasize);
if order == 2
  mwarray = varargin{1}*varargin{2}';
else
  mwvect = varargin{1};
  for i = 2:order
    mwvect = kron(varargin{i},mwvect);
  end
  mwarray(:) = mwvect;
end

