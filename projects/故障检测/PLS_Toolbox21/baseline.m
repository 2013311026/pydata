function newspec = baseline(spec,freqs,range,plots)
%BASELINE Subtracts a baseline offset from absorbance spectra
%  This function baselines absorbance spectra. It selects 
%  user specified regions that are relatively free of absorbance 
%  peaks, regresses a line through the regions, then subtracts
%  this baseline from the original spectra. Inputs are
%  the matrix of spectra (spec) the wavenumber or frequency
%  axis vector (freqs) and an m by 2 matrix (range) which specifies
%  m baselining regions. An optional input (plots) will cause
%  each spectra to be plotted when set to 1. The output is the 
%  matrix of baselined spectra newspec.
%
%I/O:  newspec = baseline(spec,freqs,range,plots);
%
%See also: LAMSEL, SAVGOL, SPECEDIT

%Copyright Eigenvector Research, Inc. 1997-8
%bmw  

[m,n] = size(spec);
if nargin == 3
  plots = 0;
end
r = lamsel(freqs,range,plots);
[mf,nf] = size(freqs);
if nf ~= n
  error('Number of columns in wavenumber axis and spectra not the same')
end
[mr,nr] = size(r);
newspec = spec;
xr = [freqs(r)' ones(nr,1)];
xb = [freqs' ones(n,1)];
for i = 1:m
  b = xr\spec(i,r)';
  newspec(i,:) = spec(i,:) - (xb*b)';
  if plots == 1
    plot(freqs,spec(i,:),freqs,newspec(i,:))
	hline(0)
	xlabel('Wavenumbers')
	ylabel('Absorbance')
	s = sprintf('Original and Baselined Spectra Number %g',i);
	title(s)
	pause
  end
end










