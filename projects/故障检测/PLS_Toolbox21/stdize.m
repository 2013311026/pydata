function stdspec = stdize(nspec,stdmat,stdvect);
%STDIZE Standardizes new spectra using previously developed transform
%  Inputs are the new spectra to be standardized (nspec),
%  the standardization matrix (stdmat) and the additive background
%  correction (stdvect). The output is the standardized spectra (stdspec).
%  The standardization matrix and background correction can be obtained
%  using the functions STDGEN, STDGENDW and STDGENNS.
%
%I/O: stdspec = stdize(nspec,stdmat,stdvect);
%
%See also: STDSSLCT, STDGEN, STDDEMO, STDGENDW, STDGENNS

%Copyright Eigenvector Research, Inc. 1997-98
%bmw 5/30/97, nbg 2/23/98,12/98

if nargin<3
  [ms,ns] = size(nspec);
  [mm,nm] = size(stdmat);
  if ns~=mm
    error('Spectrum and transfer matrix sizes not compatible')
  end
  stdspec = nspec*stdmat;
else
  [ms,ns] = size(nspec);
  [mm,nm] = size(stdmat);
  [mv,nv] = size(stdvect);
  if (ns~=mm | nm~=nv)
    error('Spectrum, transfer matrix and background vector sizes not compatible')
  end
  stdspec = nspec*stdmat + ones(ms,1)*stdvect;
end
