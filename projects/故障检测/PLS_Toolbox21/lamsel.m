function inds = lamsel(freqs,ranges,so)
%LAMSEL Determines indices of wavelength axes in specified ranges
%  This function determines the indices of the elements of a
%  wavelength or wavenumber axis within the ranges specified. 
%  The inputs are the wavelength or wavenumber axis (freqs)
%  and an m by 2 matrix defining the wavelength ranges
%  to select(ranges). An optional input (out) suppresses the
%  output when set to 0. The output is a vector of indices
%  of the channels in the specified ranges (inds).
%
%I/O: inds = lamsel(freqs,ranges,out);
%
%Example: inds = lamsel(lamda,[840 860; 1380 1400]); outputs
%  the indices of the elements of lamda between 840 and 860 and
%  between 1380 and 1400.
%
%See also: BASELINE, SAVGOL, SPECEDIT

%Copyright Eigenvector Research, Inc. 1997-98
%bmw

[m,n] = size(ranges);
nir = 0;
inds = [];
if nargin < 3
  so = 1;
end
for i = 1:m
  tmp = find(freqs <= max(ranges(i,:)) & freqs >= min(ranges(i,:)));
  [mt,nt] = size(tmp);
  if min([mt nt]) == 0
    s = sprintf('No channels were found in the range %g to %g',...
	    ranges(i,1),ranges(i,2));
	disp('  '), disp(s), disp('  ')
  else
    inds = [inds tmp];
  end
end
inds = sort(inds);
[m,n] = size(inds);
k = 0;
for i = 2:n
  if inds(i) == inds(i-1)
    k = k+1;
  end
end
if k > 0
  s = sprintf('%g channels were repeated in 2 or more of the specified ranges',k);
  disp('  '), disp(s)
  disp('You may want to adjust your ranges so they do not overlap')
end
if so ~= 0
  [mi,ni] = size(inds);
  s = sprintf('%g channels were selected',ni);
  disp('  '), disp(s), disp('  ')
end
