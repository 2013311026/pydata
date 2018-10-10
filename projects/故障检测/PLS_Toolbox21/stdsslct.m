function [specsub,specnos] = stdsslct(spec,nosamps,rinv)
%STDSSLCT Selects subset of spectra for use in standardization
%  Selects a subset of the given spectra based on leverage for
%  use in developing transforms for instrument standardization.
%  The inputs are the available spectra (spec) and the number
%  samples to be selected (nosamps). The optional input (rinv)
%  is the model inverse used for the calibration model to be 
%  used with the data. If this is supplied, samples will be 
%  selected based on their leverage on the calibration model.
%  Otherwise, they will be selected based on their distance 
%  from the multivariate mean. The outputs are the matrix
%  of spectra selected (specsub) and the sample numbers of the
%  selected spectra (specnos).
%
%I/O: [specsub,specnos] = stdsslct(spec,nosamps,rinv);
%
%See also: STDGEN, STDDEMO, STDIZE, RINVERSE

%Copyright Eigenvector Research, Inc. 1994-98
%bmw
%Modified bmw 5/96, 3/97

[ms,ns] = size(spec);
r1 = mncn(spec);
subset = zeros(1,nosamps);
for i = 1:nosamps
  if nargin < 3
    hat = r1*r1';
  else
    hat = r1*rinv;
  end
  [x subset(1,i)] = max(diag(hat));
  r0 = r1(subset(1,i),:);
  r1(subset(1,i),:) = zeros(1,ns);
  for j = 1:ms
    r1(j,:) = r1(j,:) - ((r0*r1(j,:)')/(r0*r0'))*r0;
  end
end
disp('The subset selected consists of the following samples:')
disp('  ')
disp(subset)
specnos = subset;
specsub = spec(subset,:);
